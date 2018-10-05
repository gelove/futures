package com.example.futures;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;


import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;


public class MainActivity extends FlutterActivity {
    private static final String QUOTATION_CHANNEL = "futures.flutter.io/quotation";
    private static final String BATTERY_CHANNEL = "futures.flutter.io/battery";
    private static final String CHARGING_CHANNEL = "futures.flutter.io/charging";
    private static final String MdListEvent = "mdListEvent";
    private static final String MdDataEvent = "mdDataEvent";
    private static final String SOCKET_SERVER = "http://192.168.2.211:12345/";

    private MethodChannel quotationChanel;

    private Socket mSocket;

    {
        try {
            // 初始化socket.io，设置链接
            mSocket = IO.socket(SOCKET_SERVER);
        } catch (URISyntaxException e) {
            System.out.println(e);
        }
    }

    public static ArrayList<HashMap> convert(JSONArray jArr) {
        ArrayList<HashMap> list = new ArrayList<HashMap>();
        try {
            for (int i = 0, l = jArr.length(); i < l; i++) {
                list.add(JsonToMap(jArr.getJSONObject(i)));
            }
        } catch (JSONException e) {
            System.out.println(e);
        }

        return list;
    }

    public static HashMap<String, HashMap> convertToMap(JSONArray jArr) {
        HashMap<String, HashMap> map = new HashMap<String, HashMap>();
        try {
            for (int i = 0, l = jArr.length(); i < l; i++) {
                map.put(jArr.getJSONObject(i).getString("ContractNo"), JsonToMap(jArr.getJSONObject(i)));
//                map.add(JsonToMap(jArr.getJSONObject(i)));
            }
        } catch (JSONException e) {
            System.out.println(e);
        }

        return map;
    }

    /**
     * 将json对象转换成Map
     *
     * @param jsonObject json对象
     * @return Map对象
     */
    @SuppressWarnings("unchecked")
    public static HashMap<String, String> JsonToMap(JSONObject jsonObject) {
        HashMap<String, String> result = new HashMap<String, String>();
        Iterator<String> iterator = jsonObject.keys();
        String key = null;
        String value = null;
        while (iterator.hasNext()) {
            key = iterator.next();
            try {
                value = jsonObject.getString(key);
                result.put(key, value);
            } catch (JSONException e) {
                System.out.println(e);
                continue;
            }
        }
        return result;
    }

    private Emitter.Listener onConnect = new Emitter.Listener() {
        @Override
        public void call(Object... args) {
            mSocket.emit("registerEvent", "{\"flag\": \"list\"}");
        }
    };

    private Emitter.Listener onDisconnect = new Emitter.Listener() {
        @Override
        public void call(Object... args) {
        }
    };

    private Emitter.Listener onMdListEvent = new Emitter.Listener() {
        @Override
        public void call(Object... args) {
            quotationChanel.invokeMethod("initQuotation", args[0].toString());
//            JSONObject obj = (JSONObject) args[0];
//            try {
//                JSONArray list = obj.getJSONArray("dataList");
//                System.out.println(list);
//                quotationChanel.invokeMethod("initQuotation", convertToMap(list));
//            } catch (JSONException e) {
//                System.out.println(e);
//                return;
//            }
        }
    };

    private Emitter.Listener onMdDataEvent = new Emitter.Listener() {
        @Override
        public void call(Object... args) {
            quotationChanel.invokeMethod("setQuotation", args[0].toString());
//            JSONArray arr = (JSONArray) args[0];
//            System.out.println(arr);
//            quotationChanel.invokeMethod("setQuotation", convert(arr));
        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        quotationChanel = new MethodChannel(getFlutterView(), QUOTATION_CHANNEL);

        quotationChanel.setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (call.method.equals("getBatteryLevel")) {
                            int batteryLevel = getBatteryLevel();

                            if (batteryLevel != -1) {
                                result.success(batteryLevel);
                            } else {
                                result.error("UNAVAILABLE", "Battery level not available.", null);
                            }
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );

        new EventChannel(getFlutterView(), CHARGING_CHANNEL).setStreamHandler(
                new StreamHandler() {
                    private BroadcastReceiver chargingStateChangeReceiver;

                    @Override
                    public void onListen(Object arguments, EventSink events) {
                        chargingStateChangeReceiver = createChargingStateChangeReceiver(events);
                        registerReceiver(
                                chargingStateChangeReceiver, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        unregisterReceiver(chargingStateChangeReceiver);
                        chargingStateChangeReceiver = null;
                    }
                }
        );

        new MethodChannel(getFlutterView(), BATTERY_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (call.method.equals("getBatteryLevel")) {
                            int batteryLevel = getBatteryLevel();

                            if (batteryLevel != -1) {
                                result.success(batteryLevel);
                            } else {
                                result.error("UNAVAILABLE", "Battery level not available.", null);
                            }
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );

        mSocket.on(Socket.EVENT_CONNECT, onConnect)
                .on(Socket.EVENT_DISCONNECT, onDisconnect)
                .on(MdListEvent, onMdListEvent)
                .on(MdDataEvent, onMdDataEvent);

        // 建立socket.io服务器的连接
        mSocket.connect();
    }

    @Override
    public void onDestroy() {
        mSocket.off(Socket.EVENT_CONNECT);
        mSocket.off(Socket.EVENT_DISCONNECT);
        mSocket.off(MdListEvent);
        mSocket.off(MdDataEvent);
        mSocket.disconnect();
        super.onDestroy();
    }

    private BroadcastReceiver createChargingStateChangeReceiver(final EventSink events) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                int status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1);

                if (status == BatteryManager.BATTERY_STATUS_UNKNOWN) {
                    events.error("UNAVAILABLE", "Charging status unavailable", null);
                } else {
                    boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL;
                    events.success(isCharging ? "charging" : "discharging");
                }
            }
        };
    }

    private int getBatteryLevel() {
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            return (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
    }
}
