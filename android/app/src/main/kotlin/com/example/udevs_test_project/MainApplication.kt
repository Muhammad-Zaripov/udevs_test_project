package com.example.udevs_test_project

import android.app.Application

import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setApiKey("46952e3a-f76d-4fad-976a-4df4536460cf") 
  }
}