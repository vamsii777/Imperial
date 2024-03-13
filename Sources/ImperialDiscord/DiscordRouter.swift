import Vapor
import Foundation

public class DiscordRouter: FederatedServiceRouter {
    

    public static var baseURL: String = "https://discord.com/"
    public static var callbackURL: String = "callback"
    public let tokens: FederatedServiceTokens
    public let callbackCompletion: (Request, String) async throws -> Response
    public var scope: [String] = []
    public let callbackURL: String
    public let accessTokenURL: String = "\(DiscordRouter.baseURL.finished(with: "/"))api/oauth2/token"
    public let service: OAuthService = .discord
    public let callbackHeaders = HTTPHeaders([("Content-Type", "application/x-www-form-urlencoded")])

    public required init(callback: String, completion: @escaping (Request, String) async throws -> Response) throws {
        self.tokens = try DiscordAuth()
        self.callbackURL = callback
        self.callbackCompletion = completion
    }

    public func authURL(_ request: Request) throws -> String {

        var components = URLComponents()
        components.scheme = "https"
        components.host = "discord.com"
        components.path = "/api/oauth2/authorize"
        components.queryItems = [
            clientIDItem,
            .init(name: "redirect_uri", value: DiscordRouter.callbackURL),
            .init(name: "response_type", value: "code"),
            scopeItem
        ]

        guard let url = components.url else {
            throw Abort(.internalServerError)
        }

        return url.absoluteString
    }

    public func callbackBody(with code: String) -> any Content {
        return DiscordCallbackBody(
            clientId: tokens.clientID,
            clientSecret: tokens.clientSecret,
            grantType: "authorization_code",
            code: code,
            redirectUri: DiscordRouter.callbackURL,
            scope: scope.joined(separator: " ")
        )
    }

}
