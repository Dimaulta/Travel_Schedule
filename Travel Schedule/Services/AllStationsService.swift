//
//  AllStationsService.swift
//  Travel Schedule
//
//  Created by Ульта on 30.09.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias AllStationsResponse = Components.Schemas.AllStationsResponse

protocol AllStationsServiceProtocol {
  func getAllStations(
    apikey: String,
    lang: String?,
    format: String?
  ) async throws -> AllStationsResponse
}

final class AllStationsService: AllStationsServiceProtocol {
  private let client: Client

  init(client: Client) {
    self.client = client
  }

  func getAllStations(
    apikey: String,
    lang: String? = nil,
    format: String? = nil
  ) async throws -> AllStationsResponse {
    let response = try await client.getAllStations(query: .init(
      apikey: apikey,
      lang: lang,
      format: format
    ))
    return try response.ok.body.json
  }
}
