package com.example.android.comsci117;

import android.content.Context;
import android.content.SharedPreferences;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.CountDownTimer;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.wahoofitness.connector.HardwareConnector;
import com.wahoofitness.connector.HardwareConnectorEnums;
import com.wahoofitness.connector.HardwareConnectorTypes;
import com.wahoofitness.connector.capabilities.Capability;
import com.wahoofitness.connector.capabilities.Heartrate;
import com.wahoofitness.connector.conn.connections.SensorConnection;
import com.wahoofitness.connector.conn.connections.params.ConnectionParams;
import com.wahoofitness.connector.listeners.discovery.DiscoveryListener;

import org.w3c.dom.Text;

import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.TimeUnit;

import static java.lang.Math.min;


public class MainActivity extends AppCompatActivity implements SensorEventListener {

    private static final String TAG = "MyActivity";
    String month, day;
    public TextView heartbeat;
    TextView steps_titleTV;
    TextView stepsTV;
    TextView heartbeat_title;
    TextView heartbeat;
    Button resetButton;
    Button start_hr;
    int total_steps;
    int recent_steps;
    int current_steps = 15;
    int i = 0;
    boolean active = false;

    SensorManager sensorManager;
    DiscoveryListener discover_listener;
    HeartbeatServices mHeartbeatServices;
    ConnectionParams mConnectionParams;
    Heartrate hr;
    Heartrate.Listener mHeartrateListener;
    SensorConnection.Listener heartrate_listener;

    private HardwareConnector mHardwareConnector;
    private SensorConnection mSensorConnection;
    private final HardwareConnector.Callback mHardwareConnectorCallback = new HardwareConnector.Callback() {
        @Override
        public void disconnectedSensor(SensorConnection sensorConnection) { return; }

        @Override
        public void connectorStateChanged(HardwareConnectorTypes.NetworkType networkType, HardwareConnectorEnums.HardwareConnectorState hardwareConnectorState) { return; }

        @Override
        public void connectedSensor(SensorConnection sensorConnection) { return; }

        @Override
        public void onFirmwareUpdateRequired(SensorConnection sensorConnection, String s, String s1) {}

        @Override
        public void hasData() {}
    };


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        heartbeat = (TextView) findViewById(R.id.heartbeat);
        heartbeat_title = (TextView) findViewById(R.id.heartbeat_title);
        steps_titleTV = (TextView) findViewById(R.id.steps_title);
        stepsTV = (TextView) findViewById(R.id.steps);
        resetButton = (Button) findViewById(R.id.reset_button);
        start_hr = (Button) findViewById(R.id.start_hr);

        SharedPreferences saved_steps = getSharedPreferences("saved_steps", Context.MODE_PRIVATE);
        recent_steps = saved_steps.getInt("recentSteps", -1);

        resetButton.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {

                SharedPreferences saved_steps = getSharedPreferences("saved_steps", Context.MODE_PRIVATE);
                SharedPreferences.Editor editor = saved_steps.edit();
                editor.putInt("recentSteps", total_steps);
                editor.commit();
                current_steps = total_steps - saved_steps.getInt("recentSteps", -1);

                stepsTV.setText(String.valueOf(current_steps));
            }
        });

        start_hr.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                if (heartbeat.getText().equals("stop"))
                {
                    timerHandler.removeCallbacks(timerRunnable);
                }
                else
                {
                    i = 0;
                    startTime = System.currentTimeMillis();
                    timerHandler.postDelayed(timerRunnable, 2000);
                }
            }
        });


        discover_listener = new DiscoveryListener()
        {
            public void onDeviceDiscovered(ConnectionParams connectionParams)
            {
                Toast.makeText(MainActivity.this, "Discovered heartrate device.", Toast.LENGTH_LONG).show();
                Log.d(TAG, "Found heartrate device");
                heartrate_listener = new SensorConnection.Listener()
                {
                    @Override
                    public void onSensorConnectionStateChanged(SensorConnection sensorConnection, HardwareConnectorEnums.SensorConnectionState sensorConnectionState) {}

                    @Override
                    public void onSensorConnectionError(SensorConnection sensorConnection, HardwareConnectorEnums.SensorConnectionError sensorConnectionError) {}

                    @Override
                    public void onNewCapabilityDetected(SensorConnection sensorConnection, Capability.CapabilityType capabilityType)
                    {
                        if (capabilityType == Capability.CapabilityType.Heartrate)
                        {
                            hr = (Heartrate) sensorConnection.getCurrentCapability(Capability.CapabilityType.Heartrate);
                            hr.addListener(mHeartrateListener);
                        }
                    }
                };
            }

            public void onDiscoveredDeviceLost(ConnectionParams connectionParams)
            {
                Toast.makeText(MainActivity.this, "Lost connections to heartrate device.", Toast.LENGTH_LONG).show();
            }

            public void onDiscoveredDeviceRssiChanged(ConnectionParams connectionParams, int i) {}
        };


        mHardwareConnector = new HardwareConnector(this, mHardwareConnectorCallback);
        mHardwareConnector.startDiscovery(HardwareConnectorTypes.SensorType.HEARTRATE, HardwareConnectorTypes.NetworkType.BTLE, discover_listener);
    }

    Heartrate.Data getHeartRateData()
    {
      if (mSensorConnection != null && hr != null)
      {
          heartbeat.setText(hr.getHeartrateData().getHeartrate().toString());
          return hr.getHeartrateData();
      }
      else
        return null;
    }

    long startTime = 0;

    Handler timerHandler = new Handler();
    Runnable timerRunnable = new Runnable()
    {
        @Override
        public void run()
        {
            Log.v("Nothing", String.valueOf(current_steps));

            if (i < 11)
            {
                heartbeat.setText(String.format("%d", getHeartRateData()));
                i++;
            }
            else
            {
                heartbeat.setText("--");
            }
            timerHandler.postDelayed(this, 2000);
        }
    };

    public int aa(int it)
    {
        return it + 1;
    }
    public void startHRfunction(View view){}

    @Override
    public void onSensorChanged(SensorEvent event)
    {
        total_steps = (int) event.values[0];
        if (active == true)
        {
            SharedPreferences saved_steps = getSharedPreferences("saved_steps", Context.MODE_PRIVATE);
            recent_steps = saved_steps.getInt("recentSteps", -1);
            current_steps = total_steps - recent_steps;
            stepsTV.setText(String.valueOf(current_steps));
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {}

    @Override
    protected void onResume()
    {
        super.onResume();
        active = true;
        Sensor countSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER);

        if (countSensor != null)
        {
            sensorManager.registerListener(this, countSensor, sensorManager.SENSOR_DELAY_UI);
        }
        else
        {
            Toast.makeText(this, "Cannot find sensor", Toast.LENGTH_LONG).show();
        }
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        active = false;
    }
}
