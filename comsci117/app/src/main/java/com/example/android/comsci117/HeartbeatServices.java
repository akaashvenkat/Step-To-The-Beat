package com.example.android.comsci117;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.widget.Toast;

import com.wahoofitness.connector.HardwareConnector;
import com.wahoofitness.connector.HardwareConnectorEnums;
import com.wahoofitness.connector.HardwareConnectorTypes;
import com.wahoofitness.connector.conn.connections.SensorConnection;
import com.wahoofitness.connector.conn.connections.params.ConnectionParams;
import com.wahoofitness.connector.listeners.discovery.DiscoveryListener;
import com.wahoofitness.connector.listeners.discovery.DiscoveryResult;

import static com.wahoofitness.connector.HardwareConnectorTypes.SensorType.HEARTRATE;

/**
 * Created by there on 5/12/2018.
 */

public class HeartbeatServices extends Service {
    private HardwareConnector mHardwareConnector;


    private final HardwareConnector.Callback mHardwareConnectorCallback = new HardwareConnector.Callback(){
        @Override
        public void disconnectedSensor(SensorConnection sensorConnection) {
            return;
        }

        @Override
        public void connectorStateChanged(HardwareConnectorTypes.NetworkType networkType, HardwareConnectorEnums.HardwareConnectorState hardwareConnectorState) {
            return;
        }

        @Override
        public void connectedSensor(SensorConnection sensorConnection) {
            return;
        }

        @Override
        public void onFirmwareUpdateRequired(SensorConnection sensorConnection, String s, String s1) {

        }

        @Override
        public void hasData() {

        }
    };

    public IBinder onBind(Intent a) {
        return null;
    }

    public void onCreate(){
        super.onCreate();
        mHardwareConnector= new HardwareConnector(this,mHardwareConnectorCallback);

        DiscoveryListener discover_listener = new DiscoveryListener() {
            @Override
            public void onDeviceDiscovered(ConnectionParams connectionParams) {
                Toast.makeText(HeartbeatServices.this,"Discovered heartrate device.", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onDiscoveredDeviceLost(ConnectionParams connectionParams) {
                Toast.makeText(HeartbeatServices.this,"Lost connections to heartrate device.", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onDiscoveredDeviceRssiChanged(ConnectionParams connectionParams, int i) {
            }
        };

        mHardwareConnector.startDiscovery(HEARTRATE, HardwareConnectorTypes.NetworkType.BTLE, discover_listener);

        
        SensorConnection sc = mHardwareConnector.requestSensorConnection();

        mHardwareConnector.stopDiscovery(HardwareConnectorTypes.NetworkType.BTLE);

    }

    public void onDestroy(){
        super.onDestroy();
        mHardwareConnector.shutdown();
    }
}
