@file:OptIn(ExperimentalJsExport::class)

package com.nostratech.modula

import kotlin.js.JsExport
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName
import kotlinx.serialization.json.Json
import kotlin.js.ExperimentalJsExport

@JsExport
@Serializable
data class SDUIStyle(
    val width: String? = null, // "match_parent", "wrap_content", or numeric string e.g. "100"
    val height: String? = null,
    val backgroundColor: String? = null,
    val align: String? = null,
    val arrangement: String? = null,
    val scrollable: Boolean? = null,
    val margin: SDUIMargin? = null,
    val padding: SDUIPadding? = null,
    val round: String? = null
)

@Serializable
@JsExport
data class SDUIMargin(
    val left: Double? = 0.0,
    val top: Double? = 0.0,
    val right: Double? = 0.0,
    val bottom: Double? = 0.0
)

@Serializable
@JsExport
data class SDUIPadding(
    val left: Double? = 0.0,
    val top: Double? = 0.0,
    val right: Double? = 0.0,
    val bottom: Double? = 0.0
)

@JsExport
@Serializable
sealed class SDUIComponent {
    abstract val style: SDUIStyle?

    val type: String
        get() = when (this) {
            is TextComponent -> "text"
            is ButtonComponent -> "button"
            is ContainerComponent -> "container"
            is ColumnComponent -> "column"
            is RowComponent -> "row"
        }
}

@SerialName("text")
@JsExport
@Serializable
data class TextComponent(
    val text: String,
    val fontSize: Int? = null,
    val color: String? = null,
    override val style: SDUIStyle? = null
) : SDUIComponent()

@SerialName("button")
@JsExport
@Serializable
data class ButtonComponent(
    val label: String,
    val action: String,
    override val style: SDUIStyle? = null
) : SDUIComponent()

@SerialName("container")
@JsExport
@Serializable
data class ContainerComponent(
    val children: List<SDUIComponent>,
    override val style: SDUIStyle? = null
) : SDUIComponent() {
    val childrenArray: Array<SDUIComponent> get() = children.toTypedArray()
}

@SerialName("column")
@JsExport
@Serializable
data class ColumnComponent(
    val children: List<SDUIComponent>,
    override val style: SDUIStyle? = null
) : SDUIComponent() {
    val childrenArray: Array<SDUIComponent> get() = children.toTypedArray()
}

@SerialName("row")
@JsExport
@Serializable
data class RowComponent(
    val children: List<SDUIComponent>,
    override val style: SDUIStyle? = null
) : SDUIComponent() {
    val childrenArray: Array<SDUIComponent> get() = children.toTypedArray()
}

val sduiJson = Json {
    ignoreUnknownKeys = true
    classDiscriminator = "type"
}

@JsExport
class SduiParser {
    fun parse(json: String): List<SDUIComponent> {
        return try {
            val trimmed = json.trim()
            if (trimmed.startsWith("[")) {
                sduiJson.decodeFromString<List<SDUIComponent>>(trimmed)
            } else {
                listOf(sduiJson.decodeFromString<SDUIComponent>(trimmed))
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    fun parseAsArray(json: String): Array<SDUIComponent> {
        return parse(json).toTypedArray()
    }

    fun getMockData(): String {
        return """
  {
    "type": "column",
    "style": {
      "width": "match_parent",
      "backgroundColor": "#F5F7FA",
      "padding": { "top": 40, "left": 16, "right": 16, "bottom": 40 }
    },
    "children": [
      {
        "type": "text",
        "text": "SDUI Unified Layout",
        "fontSize": 28,
        "color": "#1A1A1A",
        "style": { "margin": { "bottom": 8 } }
      },
      {
        "type": "text",
        "text": "Build once, render beautifully on Android, iOS, and Web.",
        "fontSize": 16,
        "color": "#666666",
        "style": { "align": "center", "margin": { "bottom": 32 } }
      },
      {
        "type": "row",
        "style": {
          "width": "match_parent",
          "arrangement": "space-between",
          "margin": { "bottom": 32 }
        },
        "children": [
          {
            "type": "button",
            "label": "Home",
            "action": "go_home"
          },
          {
            "type": "button",
            "label": "Profile",
            "action": "go_profile"
          },
          {
            "type": "button",
            "label": "Settings",
            "action": "go_settings"
          }
        ]
      },
      {
        "type": "column",
        "style": {
          "width": "match_parent",
          "backgroundColor": "#FFFFFF",
          "round": "16",
          "padding": { "top": 24, "bottom": 24, "left": 20, "right": 20 }
        },
        "children": [
          {
            "type": "text",
            "text": "Beautiful Containers",
            "fontSize": 20,
            "color": "#1A1A1A",
            "style": { "margin": { "bottom": 12 } }
          },
          {
            "type": "text",
            "text": "Containers support padding, margin, exact or responsive dimensions, layout arrangements, scaling, and rounded corners natively in the framework.",
            "fontSize": 16,
            "color": "#444444"
          }
        ]
      }
    ]
  }
        """.trimIndent()
    }

    fun componentsToJson(components: List<SDUIComponent>): String {
        return sduiJson.encodeToString(components)
    }
}
