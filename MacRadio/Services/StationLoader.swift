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

            let data = try Data(
                contentsOf: url
            )


            let stations = try JSONDecoder().decode(
                [RadioStation].self,
                from: data
            )


            print(
                "Stations loaded:",
                stations.count
            )


            return stations


        } catch {

            print(
                "Station loading error:",
                error
            )

            return []

        }

    }

}
