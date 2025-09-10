package com.vinhnt.meow_app

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.content.Intent
import android.content.Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
import android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider.getUriForFile
import androidx.core.graphics.drawable.toBitmap
import androidx.core.graphics.drawable.toBitmapOrNull
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.CircularProgressIndicator
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.ImageProvider
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.appwidget.updateAll
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.state.PreferencesGlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import coil.Coil
import coil.annotation.ExperimentalCoilApi
import coil.compose.AsyncImage
import coil.imageLoader
import coil.memory.MemoryCache
import coil.request.CachePolicy
import coil.request.ErrorResult
import coil.request.ImageRequest
import coil.request.SuccessResult
import es.antonborri.home_widget.actionStartActivity
import kotlinx.coroutines.launch
import java.io.File

class AppWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<*>?
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val data = currentState.preferences
        val imagePath = data.getString("app_url", null) ?: "https://cdn2.thecatapi.com/images/20o.jpg"

        var randomImage by remember(imagePath) { mutableStateOf<Bitmap?>(null) }

        LaunchedEffect(imagePath) {
            randomImage = context.getRandomImage(imagePath)
        }

        Box(
            modifier = GlanceModifier.background(Color.White).padding(8.dp).clickable(
                onClick = actionStartActivity<MainActivity>(
                    context,
                    Uri.parse("appWidget://message?image_url=$imagePath")
                )
            )
        ) {
            Box(
                modifier = GlanceModifier.fillMaxSize().cornerRadius(8.dp),
            ) {
                imagePath?.let {
                    Box {
                        if (randomImage != null) {
                            Image(
                                provider = ImageProvider(randomImage!!),
                                contentDescription = "Image from Meow App",
                                contentScale = ContentScale.Crop,
                                modifier = GlanceModifier.fillMaxSize()

                            )
                        } else {
                            CircularProgressIndicator()
                        }
                        Box(
                            modifier = GlanceModifier.padding(8.dp).cornerRadius(40.dp)
                        ) {
                            Image(
                                provider = ImageProvider(R.mipmap.ic_launcher), // your launcher icon
                                contentDescription = "App icon", modifier = GlanceModifier.size(36.dp)
                            )
                        }
                    }
                } ?: Box {
                    ////TODO: show ảnh default và dòng chữ Mở app để chọn ảnh
                }
            }
        }
    }

    private suspend fun Context.getRandomImage(url: String, force: Boolean = false): Bitmap? {
        val request = ImageRequest.Builder(this).data(url).apply {
            if (force) {
                memoryCachePolicy(CachePolicy.DISABLED)
                diskCachePolicy(CachePolicy.DISABLED)
            }
        }.build()

        // Request the image to be loaded and throw error if it failed
        return when (val result = imageLoader.execute(request)) {
            is ErrorResult -> throw result.throwable
            is SuccessResult -> result.drawable.toBitmapOrNull()
        }
    }
}
