
package com.bixolon.bxlflutterbgatelib;
import androidx.annotation.NonNull;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.net.Uri;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.Semaphore;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import com.bixolon.BixolonConst;
import com.bixolon.mpos.MPosControllerScanner;

/** BxlMPosControllerScannerPlugin */
public class BxlMPosControllerScannerPlugin implements FlutterPlugin, MethodCallHandler{
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private EventChannel dataChannel;
    private MPosControllerScanner scanner = new MPosControllerScanner();
    private Context context;
    private final Semaphore available = new Semaphore(1, true);
    private Integer commandMode = 0; /*BY-PASS*/
    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final String METHOD_CHANNEL = "com.bixolon.mposcontroller/scanner";
        final String DATA_EVENT_CHANNEL = "com.bixolon.mposcontroller/scanner/data";

        BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(messenger, METHOD_CHANNEL);
        channel.setMethodCallHandler(this);

        dataChannel = new EventChannel(messenger, DATA_EVENT_CHANNEL);
        dataChannel.setStreamHandler(new DataEventChannel(context));

    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        class NewRunnable implements Runnable {
            @Override
            public void run() {
                try {
                    available.acquire();
                    switch (call.method)
                    {
                        // COMMON
                        case "selectInterface":                 selectInterface(call, result); break;
                        case "selectCommandMode":               selectCommandMode(call, result); break;
                        case "openService":                     openService(call, result); break;
                        case "closeService":                    closeService(call, result); break;
                        case "isOpen":                          isOpen(call, result); break;
                        case "getDeviceId":                     getDeviceId(call, result); break;
                        case "directIO":                        directIO(call, result); break;
                        case "setReadMode":                     setReadMode(call, result); break;
                        case "setKeepNetworkConnection":        setKeepNetworkConnection(call, result); break;
                        case "setTransaction":                  setTransaction(call, result); break;
                        case "getOccuredData":                  getOccuredData(call, result); break;
                        default:
                            result.notImplemented();
                            break;
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }finally {
                    available.release();
                }
            }
        }
        NewRunnable nr = new NewRunnable();
        Thread t = new Thread(nr);
        t.start();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private Object getValue(@NonNull MethodCall call, @NonNull String key, @NonNull Object defaultValue) {
        return call.argument(key) == null ? defaultValue : call.argument(key);
    }

    public void selectInterface(@NonNull MethodCall call, @NonNull Result result) {
        Integer interfaceType = (Integer)getValue(call, "interface_type", -1);
        String address = (String)getValue(call, "address", "");
        try{
            result.success((int)scanner.selectInterface(interfaceType, address));
        }catch(Exception e){
            result.success(1000);
        }
    }

    public void selectCommandMode(@NonNull MethodCall call, @NonNull Result result) {
        Integer mode = (Integer)getValue(call, "command_mode", -1);
        commandMode = (mode == 0 || mode == 1) ? mode : commandMode;
        try{
            result.success((int)scanner.selectCommandMode(mode));
        }catch(Exception e){
            result.success(1000);
        }
    }

    public void openService(@NonNull MethodCall call, @NonNull Result result) {
        Integer id = (Integer)getValue(call, "device_id", -1);
        Integer timeout = (Integer)getValue(call, "time_out", 3);
        try{
            int apiResult = (int)scanner.openService(id, timeout, context);
            result.success(apiResult);
        }catch(Exception e){
            result.success(1000);
        }
    }

    public void closeService(@NonNull MethodCall call, @NonNull Result result) {
        Integer timeout = (Integer)getValue(call, "time_out", 3);
        try{
            result.success((int)scanner.closeService(timeout));
        }catch(Exception e){
            result.success(1000);
        }
    }

    public void isOpen(@NonNull MethodCall call, @NonNull Result result) {
        try{
            result.success(scanner.isOpen() ? 1 : 0);
        }catch(Exception e){
            result.success(0);
        }
    }

    public void getDeviceId(@NonNull MethodCall call, @NonNull Result result) {
        try{
            result.success((int)scanner.getDeviceId());
        }catch(Exception e){
            result.success(-1);
        }
    }

    public void directIO(@NonNull MethodCall call, @NonNull Result result) {
        ArrayList<Integer> dataArray = call.argument("data_array") == null ? null : call.argument("data_array");
        if(dataArray == null){
            result.success(1004);
            return;
        }
        try{
            int index = 0;
            byte[] byteArray = new byte[dataArray.toArray().length];
            Iterator<Integer> iterator = dataArray.iterator();
            while(iterator.hasNext()){
                byteArray[index++] = iterator.next().byteValue();
            }
            result.success((int)scanner.directIO(byteArray));
        }catch(Exception e){
            result.success(1000);
        }
    }

    public void setReadMode(@NonNull MethodCall call, @NonNull Result result) {
        Integer mode = (Integer)getValue(call, "read_mode", 0);
        try{
            result.success((int)scanner.setReadMode(mode));
        }catch(Exception e){
            result.success(1000);
        }
    }

    public void setKeepNetworkConnection(@NonNull MethodCall call, @NonNull Result result) {
        Integer keep_connection = (Integer)getValue(call, "keep_connection", 0);
        result.success(1000);
    }

    public void setTransaction(@NonNull MethodCall call, @NonNull Result result) {
        Integer transaction = (Integer)getValue(call, "transaction", 0);
        try{
            result.success((int)scanner.setTransaction(transaction));
        }catch(Exception e){
            result.success(1000);
        }
    }

    public byte[] getOccuredData(@NonNull MethodCall call, @NonNull Result result) {
        byte[] data = null;
        try{
            data = scanner.getOccuredData();
            result.success(data);
        }catch(Exception e){
            result.success(1000);
        }
        return data;
    }

}
