package com.example.ac_sdk

import android.view.View

object Util {
    fun getViewId(view: View): Long {
        if (view.id == View.NO_ID) {
            view.id = View.generateViewId()
        }
        return view.id.toLong()
    }
}