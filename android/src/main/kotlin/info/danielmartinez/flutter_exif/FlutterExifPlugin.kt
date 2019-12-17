package info.danielmartinez.flutter_exif

import android.content.ContentResolver
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File

class FlutterExifPlugin (
        private val contentResolver: ContentResolver
): MethodCallHandler {

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_exif")
      channel.setMethodCallHandler(FlutterExifPlugin( registrar.context().contentResolver ))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when( call.method ) {
        "filter" -> {

            val starting = call.argument<Int>("starting")
            if (starting == null) {
                result.error( "01", "Starting datetime is null", null )
                return
            }
            val ending = call.argument<Int>("ending")
            if (ending == null) {
                result.error( "02", "Ending datetime is null", null )
                return
            }

            var n = call.argument<Int>("max")
            if (n == null) {
                n = 12
            }

            val uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI

            val projection = arrayOf(
                    MediaStore.Images.ImageColumns.BUCKET_ID,
                    MediaStore.Images.ImageColumns.BUCKET_DISPLAY_NAME,
                    MediaStore.Images.ImageColumns.DATE_TAKEN,
                    MediaStore.Images.ImageColumns.WIDTH,
                    MediaStore.Images.ImageColumns.HEIGHT,
                    MediaStore.Images.ImageColumns.LATITUDE,
                    MediaStore.Images.ImageColumns.LONGITUDE,
                    MediaStore.Images.ImageColumns.DATA
            )

            val selection = "${MediaStore.Images.ImageColumns.DATE_TAKEN} >= ? and ${MediaStore.Images.ImageColumns.DATE_TAKEN} <= ?"

            val cursor = contentResolver.query( uri, projection, selection, arrayOf( "$starting", "$ending" ), null )
            if (cursor != null) {

                if (cursor.count == 0) {
                    result.success( mutableListOf<Map<String,Any>>() )
                    return
                }

                val maps = mutableListOf<Map<String,Any>>()

                val indexData = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
                val indexFolderName = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)
                val indexDateTaken = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_TAKEN)
                val indexLatitude = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.LATITUDE)
                val indexLongitude = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.LONGITUDE)
                val indexWidth = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.WIDTH)
                val indexHeight = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.HEIGHT)
                while (cursor.moveToNext()) {

                    if (!cursor.isNull(indexLatitude) && !cursor.isNull(indexLongitude)) {

                        val absolutePathOfImage = cursor.getString(indexData)

                        val bucket = cursor.getString(indexFolderName)
                        val dateTaken = cursor.getDouble(indexDateTaken)
                        val latitude = cursor.getDouble(indexLatitude)
                        val longitude = cursor.getDouble(indexLongitude)
                        val width = cursor.getInt(indexWidth)
                        val height = cursor.getInt(indexHeight)

                        val map: Map<String, Any> = mapOf(
                                "identifier" to absolutePathOfImage,
                                "width" to width,
                                "height" to height,
                                "latitude" to latitude,
                                "longitude" to longitude,
                                "createdAt" to dateTaken
                        )

                        maps.add( map )

                    }

                }

                // Sorting
                val mapsShuffled = maps.shuffled()

                // Retrieve the firsts 'n' elements
                val filteredMaps = mapsShuffled.subList( 0, n-1 )

                // Re-sorting by 'createdAt'
                val sortedMaps = filteredMaps.sortedBy { it["createdAt"] as Double }

                result.success( sortedMaps )

            }

            cursor?.close()

        }
        "image" -> {

            val identifier = call.argument<String>("id")
            if (identifier == null) {
                result.error( "03", "identifier is null", null )
                return
            }

            var width = call.argument<Int>("width")
            if (width == null) {
                width = 64
            }

            var height = call.argument<Int>("height")
            if (height == null) {
                height = 64
            }

            val file = File( identifier )
            if (file.exists()) {
                result.success( file.readBytes() )
            } else {
                result.error( "04", "Image not found", null )
            }

        }
        "getPlatformVersion" -> {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        else -> {
            result.notImplemented()
        }
    }
  }

}
