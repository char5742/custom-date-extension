/*
 * Copyright 2025 Custom Date Extension Contributors
 *
 * Licensed under the MIT License (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://opensource.org/licenses/MIT
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define DUCKDB_EXTENSION_MAIN

#include "custom_date_extension.hpp"
#include "duckdb.hpp"
#include "duckdb/common/exception.hpp"
#include "duckdb/common/string_util.hpp"
#include "duckdb/function/scalar_function.hpp"
#include "duckdb/main/extension_util.hpp"
#include "duckdb/common/types/date.hpp"
#include "duckdb/function/cast/cast_function_set.hpp"

namespace duckdb {

// Helper function to validate and parse YYYY.MM.DD format
static bool TryParseCustomDate(const string &date_str, date_t &result) {
    // Check YYYY.MM.DD format
    if (date_str.length() != 10) return false;
    if (date_str[4] != '.' || date_str[7] != '.') return false;
    
    // Check if parts are numeric
    for (size_t i = 0; i < date_str.length(); i++) {
        if (i == 4 || i == 7) continue;
        if (!std::isdigit(date_str[i])) return false;
    }
    
    // Parse date parts
    try {
        int year = std::stoi(date_str.substr(0, 4));
        int month = std::stoi(date_str.substr(5, 2));
        int day = std::stoi(date_str.substr(8, 2));
        
        // Use DuckDB's Date::FromDate to validate and create date
        if (!Date::IsValid(year, month, day)) {
            return false;
        }
        
        result = Date::FromDate(year, month, day);
        return true;
    } catch (...) {
        return false;
    }
}

// Custom cast function from VARCHAR to DATE for YYYY.MM.DD format
static bool CustomDateCast(Vector &source, Vector &result, idx_t count, CastParameters &parameters) {
    UnaryExecutor::ExecuteWithNulls<string_t, date_t>(
        source, result, count,
        [&](string_t input, ValidityMask &mask, idx_t idx) {
            date_t date_result;
            
            // First try the custom format
            if (TryParseCustomDate(input.GetString(), date_result)) {
                return date_result;
            }
            
            // If custom format fails, try standard DuckDB date parsing
            string date_string = input.GetString();
            idx_t pos = 0;
            bool special = false;
            if (Date::TryConvertDate(date_string.c_str(), date_string.length(), pos, date_result, special, false) == DateCastResult::SUCCESS) {
                return date_result;
            }
            
            // If both fail, set null
            mask.SetInvalid(idx);
            return date_t();
        });
    return true;
}

static void LoadInternal(DatabaseInstance &instance) {
    // Register the custom cast from VARCHAR to DATE
    auto &config = DBConfig::GetConfig(instance);
    auto &casts = config.GetCastFunctions();
    
    // Add custom cast function for VARCHAR -> DATE
    // This enables automatic conversion of YYYY.MM.DD format to DATE type
    casts.RegisterCastFunction(LogicalType::VARCHAR, LogicalType::DATE, 
                              BoundCastInfo(CustomDateCast), 100);
}

void CustomDateExtension::Load(DuckDB &db) {
	LoadInternal(*db.instance);
}
std::string CustomDateExtension::Name() {
	return "custom_date";
}

std::string CustomDateExtension::Version() const {
#ifdef EXT_VERSION_CUSTOM_DATE
	return EXT_VERSION_CUSTOM_DATE;
#else
	return "";
#endif
}

} // namespace duckdb

extern "C" {

DUCKDB_EXTENSION_API void custom_date_init(duckdb::DatabaseInstance &db) {
    duckdb::DuckDB db_wrapper(db);
    db_wrapper.LoadExtension<duckdb::CustomDateExtension>();
}

DUCKDB_EXTENSION_API const char *custom_date_version() {
	return duckdb::DuckDB::LibraryVersion();
}
}

#ifndef DUCKDB_EXTENSION_MAIN
#error DUCKDB_EXTENSION_MAIN not defined
#endif