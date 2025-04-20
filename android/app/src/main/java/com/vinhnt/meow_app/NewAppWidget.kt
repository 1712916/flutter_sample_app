package com.vinhnt.meow_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.squareup.picasso.Picasso
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class NewAppWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.new_app_widget)

            // Get the image URL (assuming `app_url` is the key for image URL)
            val imageUrl = widgetData.getString("app_url", null)

            // Only load the image if the URL is valid
            if (!imageUrl.isNullOrEmpty()) {
                Picasso.get()
                    .load(imageUrl)
                    .into(views, R.id.widget_image, intArrayOf(appWidgetId))
            }

            // ➕ Setup tap-to-launch app
            // ➕ Setup tap-to-launch app with URI
            // Detect App opened via Click inside Flutter
            val uri = Uri.Builder()
                .scheme("homewidget")           // ✅ no underscore
                .authority("open")              // logical name, e.g., like a route
                .appendPath("image_uri")        // treated as route name
                .appendQueryParameter("image_url", imageUrl)
                .build()

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                uri
            )

            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
