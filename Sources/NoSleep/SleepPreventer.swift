import Foundation
import IOKit.pwr_mgt
import Combine

class SleepPreventer: ObservableObject {
    @Published var isPreventingSleep = false
    @Published var lastError: String? = nil

    private var systemAssertionID: IOPMAssertionID = 0
    private var displayAssertionID: IOPMAssertionID = 0

    func start() {
        guard !isPreventingSleep else { return }
        lastError = nil

        let systemReason = "NoSleep: Prevent system sleep" as CFString
        let systemResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            systemReason,
            &systemAssertionID
        )

        guard systemResult == kIOReturnSuccess else {
            lastError = "无法创建系统睡眠断言 (错误码: \(systemResult))"
            print("[NoSleep] 创建系统睡眠断言失败: \(systemResult)")
            return
        }

        // 同时防止显示器睡眠/锁屏
        let displayReason = "NoSleep: Prevent display sleep" as CFString
        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            displayReason,
            &displayAssertionID
        )

        if displayResult != kIOReturnSuccess {
            lastError = "无法防止显示器睡眠 (错误码: \(displayResult))，但系统睡眠已阻止"
            print("[NoSleep] 创建显示器睡眠断言失败: \(displayResult)")
        }

        isPreventingSleep = true
        print("[NoSleep] 已开始保持唤醒（睡眠+锁屏）")
    }

    func stop() {
        guard isPreventingSleep else { return }
        lastError = nil

        if systemAssertionID != 0 {
            IOPMAssertionRelease(systemAssertionID)
            systemAssertionID = 0
        }

        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }

        isPreventingSleep = false
        print("[NoSleep] 已停止保持唤醒")
    }

    func toggle() {
        isPreventingSleep ? stop() : start()
    }
}
