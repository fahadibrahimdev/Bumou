package app.bumoumobile.com

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle

class ModeDetectionActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.ModeDetectionTheme);
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mode_detection)
    }
}