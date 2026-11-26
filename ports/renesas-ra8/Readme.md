# 烧录

- 使用 rfp-cli 烧录 e2studio 编译的 hex 文件，在仓库根目录执行

```bash
# DNRA8P1
rfp-cli -d RA -t jlink -if swd -p -v -run ports/renesas-ra8/boards/DNRA8P1/gcc_freertos/_CPU0/Debug/mp_gcc_freertos_CPU0.hex ports/renesas-ra8/boards/DNRA8P1/gcc_freertos/_CPU1/Debug/mp_gcc_freertos_CPU1.hex
```

# 查看输出与日志

- 使用 minicom 查看串口输出

    > DNRA8P1 CPU0 将 stdio 重定向至串口，CPU0 的日志输出通过 SEGGER RTTViewer 通道 0 输出；CPU1 的标准输出和日志通过 SEGGER RTTViewer 通道 1 输出

```bash
# 根据实际设备修改 /dev/ACM1
minicom -D /dev/ttyACM1 -b 115200
```

- 使用 `JLinkRTTViewer` 查看日志，对于 DNRA8P1，`_SEGGER_RTT` 地址一般固定为 `0x221aff50`。对于通道 1，如果已打开 `JLinkRTTViewer`，则可以通过 `Logging` -> `Start Data Logging` 进行记录，要注意通道 1 的数据只能记录到文件中。
- 如果只需要查看 CPU1 的输出，可以通过 `JLinkRTTLogger` 进行，以下 RTTAddress 地址以 DNRA8P1 为例

```bash
JLinkRTTLogger -Device R7KA8P1KF_CPU0 -If SWD -Speed 4000 -RTTAddress 0x221AFF50 -RTTChannel 1 "$HOME/Documents/$(date --rfc-3339=seconds).log"
```

