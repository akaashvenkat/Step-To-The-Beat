package com.example.android.comsci117;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import com.wahoofitness.connector.HardwareConnector;
import com.wahoofitness.connector.HardwareConnectorEnums;
import com.wahoofitness.connector.HardwareConnectorTypes;
import com.wahoofitness.connector.capabilities.Capability;
import com.wahoofitness.connector.capabilities.Heartrate;

import com.wahoofitness.connector.conn.connections.SensorConnection;
import com.wahoofitness.connector.conn.connections.params.ConnectionParams;
import com.wahoofitness.connector.listeners.discovery.DiscoveryListener;
import com.wahoofitness.connector.listeners.discovery.DiscoveryResult;

import java.util.HashSet;
import java.util.Set;

import static com.wahoofitness.connector.HardwareConnectorTypes.SensorType.CALORIMETER;
import static com.wahoofitness.connector.HardwareConnectorTypes.SensorType.HEARTRATE;

/**
 * Created by there on 5/12/2018.
 */


public class HeartbeatServices extends Service {

    public static final String TAG = "HeartBeat Service";

    public DiscoveryListener discover_listener;
    public SensorConnection mSensorConnection;
    public SensorConnection.Listener heartrate_listener;
    public Heartrate hr;
    public Heartrate.Listener mHeartrateListener;
    HardwareConnector mHardwareConnector;
    HardwareConnector.Callback mHardwareConnectorCallback;


    public IBinder onBind(Intent a) {
        return null;
    }

    public void onCreate(){
        super.onCreate();
        mHardwareConnector = new HardwareConnector(this, mHardwareConnectorCallback);

    }

    public void startDiscovery() {
        Log.d("Eroor", "Error1");

        discover_listener = new DiscoveryListener() {

            public void onDeviceDiscovered(ConnectionParams connectionParams) {
                Toast.makeText(HeartbeatServices.this,"Discovered heartrate device.", Toast.LENGTH_LONG).show();

            }

            public void onDiscoveredDeviceLost(ConnectionParams connectionParams) {
                Toast.makeText(HeartbeatServices.this,"Lost connections to heartrate device.", Toast.LENGTH_LONG).show();
            }

            public void onDiscoveredDeviceRssiChanged(ConnectionParams connectionParams, int i) {
            }
        };

        mHardwareConnector.startDiscovery(HardwareConnectorTypes.SensorType.NONE, HardwareConnectorTypes.NetworkType.BTLE, discover_listener);
    }

    public void onDeviceDiscovered(ConnectionParams connectionParams) {
        heartrate_listener = new SensorConnection.Listener() {
            @Override
            public void onSensorConnectionStateChanged(SensorConnection sensorConnection, HardwareConnectorEnums.SensorConnectionState sensorConnectionState) {

            }

            @Override
            public void onSensorConnectionError(SensorConnection sensorConnection, HardwareConnectorEnums.SensorConnectionError sensorConnectionError) {

            }

            @Override
            public void onNewCapabilityDetected(SensorConnection sensorConnection, Capability.CapabilityType capabilityType) {
                if (capabilityType == Capability.CapabilityType.Heartrate) {
                    hr = (Heartrate) sensorConnection.getCurrentCapability(Capability.CapabilityType.Heartrate);
                    hr.addListener(mHeartrateListener);
                }
            }
        };

        mSensorConnection = mHardwareConnector.requestSensorConnection(connectionParams, heartrate_listener);

        mHardwareConnector.stopDiscovery(HardwareConnectorTypes.NetworkType.BTLE);
    }

    public Heartrate.Data getHeartRateData(){
        if (mSensorConnection != null && hr != null) {
                return hr.getHeartrateData();
        }
        else return null;
    }

    public void removeDevice() {
        mSensorConnection.disconnect();
    }

    public void onDestroy(){
        super.onDestroy();
        mHardwareConnector.shutdown();
    }
}
