
package com.bixolon.bxlflutterbgatelib;
import androidx.annotation.NonNull;
import android.app.Activity;
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
import com.bixolon.mpos.MPosControllerBCD;
import com.bixolon.mpos.print.FontAttribute;

/** BxlMPosControllerBCDPlugin */
public class BxlMPosControllerBCDPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private MPosControllerBCD bcd = new MPosControllerBCD();
    private Context context;
    private final Semaphore available = new Semaphore(1, true);
    private Integer commandMode = 0; /*BY-PASS*/
    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final String METHOD_CHANNEL = "com.bixolon.mposcontroller/bcd";

        BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(messenger, METHOD_CHANNEL);
        channel.setMethodCallHandler(this);

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        class NewRunnable implements Runnable {
            @Override
            public void run() {
                try {
                    available.acquire();
                    switch (call.method) {
                        // COMMON
                        case "selectInterface":
                            selectInterface(call, result);
                            break;
                        case "selectCommandMode":
                            selectCommandMode(call, result);
                            break;
                        case "openService":
                            openService(call, result);
                            break;
                        case "closeService":
                            closeService(call, result);
                            break;
                        case "isOpen":
                            isOpen(call, result);
                            break;
                        case "getDeviceId":
                            getDeviceId(call, result);
                            break;
                        case "directIO":
                            directIO(call, result);
                            break;
                        case "setReadMode":
                            setReadMode(call, result);
                            break;
                        case "setKeepNetworkConnection":
                            setKeepNetworkConnection(call, result);
                            break;
                        case "setTransaction":
                            setTransaction(call, result);
                            break;
                        // PRINT
                        case "displayString":
                            displayString(call, result);
                            break;
                        case "cleanScreen":
                            cleanScreen(call, result);
                            break;
                        //IMAGE
                        case "storeImageFile":
                            storeImageFile(call, result);
                            break;
                        case "displayImage":
                            displayImage(call, result);
                            break;
                        case "clearImage":
                            clearImage(call, result);
                            break;
                        case "showCursor":
                            showCursor(call, result);
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
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
        Integer interfaceType = (Integer) getValue(call, "interface_type", -1);
        String address = (String) getValue(call, "address", "");
        try {
            result.success((int) bcd.selectInterface(interfaceType, address));
        } catch (Exception e) {
            result.success(1000);
        }
    }

    public void selectCommandMode(@NonNull MethodCall call, @NonNull Result result) {
        Integer mode = (Integer) getValue(call, "command_mode", -1);
        commandMode = (mode == 0 || mode == 1) ? mode : commandMode;
        try {
            result.success((int) bcd.selectCommandMode(mode));
        } catch (Exception e) {
            result.success(1000);
        }
    }

    public void openService(@NonNull MethodCall call, @NonNull Result result) {
        Integer id = (Integer) getValue(call, "device_id", -1);
        Integer timeout = (Integer) getValue(call, "time_out", 3);
        try {
            int apiResult = (int) bcd.openService(id, timeout, context);
            result.success(apiResult);
        } catch (Exception e) {
            result.success(1000);
        }
    }

    public void closeService(@NonNull MethodCall call, @NonNull Result result) {
        Integer timeout = (Integer) getValue(call, "time_out", 3);
        try {
            result.success((int) bcd.closeService(timeout));
        } catch (Exception e) {
            result.success(1000);
        }
    }

    public void isOpen(@NonNull MethodCall call, @NonNull Result result) {
        try {
            result.success(bcd.isOpen() ? 1 : 0);
        } catch (Exception e) {
            result.success(0);
        }
    }

    public void getDeviceId(@NonNull MethodCall call, @NonNull Result result) {
        try {
            result.success((int) bcd.getDeviceId());
        } catch (Exception e) {
            result.success(-1);
        }
    }

    public void directIO(@NonNull MethodCall call, @NonNull Result result) {
        ArrayList<Integer> dataArray = call.argument("data_array") == null ? null : call.argument("data_array");
        if (dataArray == null) {
            result.success(1004);
            return;
        }
        try {
            int index = 0;
            byte[] byteArray = new byte[dataArray.toArray().length];
            Iterator<Integer> iterator = dataArray.iterator();
            while (iterator.hasNext()) {
                byteArray[index++] = iterator.next().byteValue();
            }
            result.success((int) bcd.directIO(byteArray));
        } catch (Exception e) {
            result.success(1000);
        }
    }

    public void setReadMode(@NonNull MethodCall call, @NonNull Result result) {
        Integer mode = (Integer) getValue(call, "read_mode", 0);
        try {
            result.success((int) bcd.setReadMode(mode));
        } catch (Exception e) {
            result.success(1000);
        }
    }

    public void setKeepNetworkConnection(@NonNull MethodCall call, @NonNull Result result) {
        Integer keep_connection = (Integer) getValue(call, "keep_connection", 0);
        result.success(1000);
    }

    public void setTransaction(@NonNull MethodCall call, @NonNull Result result) {
        Integer transaction = (Integer) getValue(call, "transaction", 0);
        try {
            result.success((int) bcd.setTransaction(transaction));
        } catch (Exception e) {
            result.success(1000);
        }
    }

    public void displayString(@NonNull MethodCall call, @NonNull Result result) {
        String data = (String) getValue(call, "data", "");
        Integer characterSet = (Integer) getValue(call, "character_set", 0);
        Integer internationalCharacterSet = (Integer) getValue(call, "international_character_set", 0);
        Integer line = (Integer) getValue(call, "line", 0);

        try {
            result.success(bcd.displayString(data, characterSet, internationalCharacterSet, line));
        } catch (Exception e) {
            result.success("");
        }
    }

    public void cleanScreen(@NonNull MethodCall call, @NonNull Result result) {
        try {
            result.success(bcd.clearScreen());
        } catch (Exception e) {
            result.success("");
        }
    }

    public void storeImageFile(@NonNull MethodCall call, @NonNull Result result) {
        String data = (String) getValue(call, "file_name", "");
        Integer width = (Integer) getValue(call, "width", 0);
        Integer imageNumber = (Integer) getValue(call, "image_number", 0);

        try {
            result.success(bcd.storeImageFile(data, width, imageNumber));
        } catch (Exception e) {
            result.success("");
        }
    }

    public void displayImage(@NonNull MethodCall call, @NonNull Result result) {
        Integer xPos = (Integer) getValue(call, "x_pos", 0);
        Integer yPos = (Integer) getValue(call, "y_pos", 0);
        Integer imageNumber = (Integer) getValue(call, "image_number", 0);

        try {
            result.success(bcd.displayImage(xPos, yPos, imageNumber));
        } catch (Exception e) {
            result.success("");
        }
    }

    public void clearImage(@NonNull MethodCall call, @NonNull Result result) {
        Integer imageNumber = (Integer) getValue(call, "image_number", 0);

        try {
            result.success(bcd.clearImage(false, imageNumber));
        } catch (Exception e) {
            result.success("");
        }
    }

    public void showCursor(@NonNull MethodCall call, @NonNull Result result) {
        Integer cursor = (Integer) getValue(call, "cursor", 0);

        try {
            result.success(bcd.showCursor(cursor));
        } catch (Exception e) {
            result.success("");
        }
    }
}
