import Flutter
import UIKit
import Photos

public class SwiftFlutterExifPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_exif", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterExifPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "filter") {
            if let arguments = call.arguments as? [String:Any] {
                if let starting = arguments["starting"] as? Double,
                    let ending = arguments["ending"] as? Double {
                    let n = (arguments["max"] as? Int) ?? 12
                    let sDate = NSDate(timeIntervalSince1970: starting)
                    let eDate = NSDate(timeIntervalSince1970: ending)
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.predicate = NSPredicate(
                        format: "creationDate >= %@ AND creationDate <= %@",
                        sDate, eDate )
                    let fetchResult = PHAsset.fetchAssets(
                        with: PHAssetMediaType.image, options: fetchOptions )
                    retrieve( fetchResult: fetchResult, n: n ) { maps in
                        result( maps )
                    }
                } else {
                    result( [[String:Any]]() )
                }
            } else {
                result( [[String:Any]]() )
            }
        } else if (call.method == "image") {
            if let arguments = call.arguments as? [String:Any] {
                if let identifier = arguments["id"] as? String {

                    let width = (arguments["width"] as? Int) ?? 64
                    let height = (arguments["height"] as? Int) ?? 64

                    DispatchQueue.global( qos: .background ).async {

                        let requestOptions = PHImageRequestOptions()
                        requestOptions.isSynchronous = false
                        requestOptions.isNetworkAccessAllowed = true
                        requestOptions.resizeMode = .fast
                        requestOptions.deliveryMode = .fastFormat

                        let fetchResult = PHAsset.fetchAssets(
                            withLocalIdentifiers: [ identifier ],
                            options: nil )
                        let asset = fetchResult.object(at: 0)
                        PHImageManager.default().requestImage(
                            for: asset,
                            targetSize: CGSize(width: width, height: height),
                            contentMode: .aspectFill,
                            options: requestOptions) { (image, info) in

                            if let _image = image {

                                let data = UIImageJPEGRepresentation( _image, 95 )
                                result( data )

                            } else {
                                result( nil )
                            }

                        }

                    }

                }
            }
        } else {
            result("iOS " + UIDevice.current.systemVersion)
        }
    }

    private func retrieve(
        fetchResult: PHFetchResult<PHAsset>,
        n: Int,
        onComplete: @escaping ([[String:Any]]) -> ()
    ) {

        let allCount = fetchResult.count
        if allCount > 0 {

            var maps = [[String:Any]]()
            for index in 0...(allCount-1) {
                let asset = fetchResult.object(at: index)
                if let map = self.toMap( asset: asset ) {
                    maps.append( map )
                }
            }

            // Sorting
            maps.shuffle()

            // Retrieve the firsts 'n' elements
            let filteredMaps = maps.suffix( n )

            // Re-sorting by 'createdAt'
            let sortedMaps = filteredMaps.sorted { (a, b) -> Bool in
                if let _a = a["createdAt"] as? Int, let _b = b["createdAt"] as? Int {
                    return _a < _b
                } else {
                    return false
                }
            }

            onComplete( sortedMaps )

        } else {
            onComplete( [[String:Any]]() )
        }
    }

    private func toMap( asset: PHAsset ) -> [String:Any]? {
        var data = [String:Any]()
        if let location = asset.location, let creationDate = asset.creationDate {
            data["latitude"] = location.coordinate.latitude
            data["longitude"] = location.coordinate.longitude
            data["altitude"] = location.altitude
            data["createdAt"] = Int( creationDate.timeIntervalSince1970 )
        } else {
            return nil
        }
        data["width"] = asset.pixelWidth
        data["height"] = asset.pixelHeight
        data["identifier"] = asset.localIdentifier
        return data
    }
    
}
