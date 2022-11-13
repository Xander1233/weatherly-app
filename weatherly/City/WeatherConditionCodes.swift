//
//  WeatherConditionCodes.swift
//  weatherly
//
//  Created by David Neidhart on 21.10.22.
//

func codeToIconIdentifier(code: Int) -> String {
    switch code {
    case 1000:
        return "sun.max"
    case 1003:
        return "cloud.sun"
    case 1006, 1009:
        return "cloud"
    case 1030, 1135, 1147:
        return "cloud.fog"
    case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201, 1240, 1243, 1246, 1249, 1252:
        return "cloud.rain"
    case 1204, 1207:
        return "cloud.sleet"
    case 1066, 1069, 1072, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1237, 1255, 1258, 1261, 1264:
        return "cloud.snow"
    case 1273, 1276, 1279, 1282:
        return "cloud.bolt.rain"
    case 1087:
        return "cloud.bolt"
    case 1150, 1153, 1168, 1171:
        return "cloud.drizzle"
    default:
        return "questionmark"
    }
}
