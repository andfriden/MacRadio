
import Foundation

final class StationLoader {

    func load() -> [RadioStation] {

        guard let url = Bundle.main.url(
            forResource: "stations",
            withExtension: "json"
        )
        else {
            print("stations.json not found")
            return []
        }


        do {

            let data = try Data(contentsOf: url)

            return try JSONDecoder()
                .decode(
                    [RadioStation].self,
                    from: data
                )

        } catch {

            print(error)
            return []
        }
    }
}
