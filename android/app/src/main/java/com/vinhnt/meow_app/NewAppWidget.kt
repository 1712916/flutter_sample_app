package com.vinhnt.meow_app

import android.appwidget.*
import android.content.*
import android.widget.*
import com.squareup.picasso.*
import es.antonborri.home_widget.*

/**
 * Implementation of App Widget functionality.
 */
class NewAppWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            // Get reference to SharedPreferences (or some data source)
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.new_app_widget)

            // Get the image URL (assuming `app_url` is the key for image URL)
            val imageUrl = widgetData.getString("app_url", null)

            // Only load the image if the URL is valid
            if (!imageUrl.isNullOrEmpty()) {
                // Create AppWidgetTarget for Glide to load the image into the widget
                Picasso.get()
                    .load(imageUrl)  // Image URL to load
                    .into(views, R.id.widget_image, intArrayOf(appWidgetId))
            }

            // Update the widget with the modified views
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
