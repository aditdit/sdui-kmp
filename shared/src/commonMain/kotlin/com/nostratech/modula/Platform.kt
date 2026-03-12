package com.nostratech.modula

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform