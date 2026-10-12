package com.rscja.deviceapi;

import com.rscja.deviceapi.RFIDWithUHFNetworkAccessGate;
import com.rscja.deviceapi.entity.UHFTAGInfo;
import com.rscja.deviceapi.entity.AntennaNameEnum;
import com.rscja.deviceapi.entity.AntennaState;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class RFIDFixedReaderUR4 {

    public static void main(String[] args) {
        String readerIp = "192.168.99.202"; 
        int readerPort = 8888;

        System.out.println("UR-4: (Multi-Tag) 868.0 MHz");

        RFIDWithUHFNetworkAccessGate rfidReader = new RFIDWithUHFNetworkAccessGate();

        System.out.println("Connect (" + readerIp + ":" + readerPort + ")...");
        if (!rfidReader.init(readerIp, readerPort)) {
            System.err.println("Error: connect");
            return;
        }
        System.out.println("Connected.");

        try {
            System.out.println("Conf: ANT1");
            List<AntennaState> antennaList = new ArrayList<>();
            antennaList.add(new AntennaState(AntennaNameEnum.ANT1, true));
            rfidReader.setAntenna(antennaList);

            System.out.println("Conf: 30 dBm");
            rfidReader.setPower(AntennaNameEnum.ANT1, 30);

            rfidReader.setRFLink(3);

            System.out.println("Conf: fixed 868.0 MHz");
            if (rfidReader.setFreHop(868.0f)) {
                System.out.println("fixed 868.0 MHz");
            } else {
                System.err.println("freq. error");
            }

            Map<String, String> detectedTags = new LinkedHashMap<>();
            
            if (rfidReader.startInventoryTag()) {
                long startTime = System.currentTimeMillis();
                
                // read 3 sec.
                while (System.currentTimeMillis() - startTime < 3000) {
                    UHFTAGInfo tagInfo = rfidReader.readTagFromBuffer();
                    
                    if (tagInfo != null && tagInfo.getEPC() != null && !tagInfo.getEPC().isEmpty()) {
                        String epc = tagInfo.getEPC();
                        String rssi = tagInfo.getRssi() != null ? tagInfo.getRssi() + " dBm" : "N/A";
                        
                        detectedTags.put(epc, rssi);
                    }
                    
                    Thread.sleep(10);
                }
                
                rfidReader.stopInventory();
            } else {
                System.err.println("Error: startInventoryTag.");
            }

            System.out.println("\n=================================================================");
            System.out.println("Tag no.: " + detectedTags.size());
            
            if (!detectedTags.isEmpty()) {
                int index = 1;
                for (Map.Entry<String, String> entry : detectedTags.entrySet()) {
                    System.out.format("[%d] EPC: %s | RSSI: %s\n", index++, entry.getKey(), entry.getValue());
                }
            } else {
                System.out.println("no tags detected.");
            }

        } catch (Exception e) {
            System.err.println("UR-4 Error: " + e.getMessage());
            e.printStackTrace();
        } catch (Throwable t) {
            System.err.println("Error: " + t.getMessage());
        } finally {
            rfidReader.free();
        }
    }
}

