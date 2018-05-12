package com.example.android.comsci117;

import android.content.Context;
import android.content.SharedPreferences;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity implements SensorEventListener{

    boolean active = false;
    SensorManager sensorManager;
    TextView steps_titleTV;
    TextView stepsTV;
    String month, day;
    Button resetButton;
    int total_steps;
    int recent_steps;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        steps_titleTV = (TextView) findViewById(R.id.steps_title);
        stepsTV = (TextView) findViewById(R.id.steps);
        resetButton = (Button) findViewById(R.id.reset_button);

        SharedPreferences saved_steps = getSharedPreferences("saved_steps", Context.MODE_PRIVATE);
        recent_steps = saved_steps.getInt("recentSteps", -1);

        resetButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {

                SharedPreferences saved_steps = getSharedPreferences("saved_steps", Context.MODE_PRIVATE);
                SharedPreferences.Editor editor = saved_steps.edit();
                editor.putInt("recentSteps", total_steps);
                editor.commit();

                stepsTV.setText(String.valueOf(total_steps - saved_steps.getInt("recentSteps", -1)));

                Toast.makeText(MainActivity.this, String.valueOf(recent_steps), Toast.LENGTH_LONG).show();
            }
        });



    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        total_steps = (int) event.values[0];

        if(active == true) {
            SharedPreferences saved_steps = getSharedPreferences("saved_steps", Context.MODE_PRIVATE);
            recent_steps = saved_steps.getInt("recentSteps", -1);
            stepsTV.setText(String.valueOf(total_steps - recent_steps));
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    @Override
    protected void onResume() {
        super.onResume();
        active = true;
        Sensor countSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER);

        if (countSensor != null) {
            sensorManager.registerListener(this, countSensor, sensorManager.SENSOR_DELAY_UI);
        }
        else {
            Toast.makeText(this, "Cannot find sensor", Toast.LENGTH_LONG).show();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        active = false;
    }


}
