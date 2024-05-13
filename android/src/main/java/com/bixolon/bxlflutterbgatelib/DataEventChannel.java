package com.bixolon.bxlflutterbgatelib;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import io.flutter.plugin.common.EventChannel;

public class DataEventChannel implements EventChannel.StreamHandler {
    private BroadcastReceiver dataOccuredReceiver;
    private Context context;

    public DataEventChannel(Context context) {
        this.context = context;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        dataOccuredReceiver = dataOccurred(events);
        context.registerReceiver(dataOccuredReceiver, new IntentFilter(Intent.ACTION_POWER_CONNECTED));
    }

    @Override
    public void onCancel(Object arguments) {
        context.unregisterReceiver(dataOccuredReceiver);
        dataOccuredReceiver = null;
    }

    private BroadcastReceiver dataOccurred(final EventChannel.EventSink events) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                events.success(true);
            }
        };
    }
}
