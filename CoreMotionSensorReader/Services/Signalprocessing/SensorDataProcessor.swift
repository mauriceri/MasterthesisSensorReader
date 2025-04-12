//
//  SensorDataProcessor.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 24.03.25.
//


class SensorDataProcessor {
    var pitchFilter: LowPassFilter
    var yawFilter: LowPassFilter
    var rollFilter: LowPassFilter
    var rotationRateXFilter: LowPassFilter
    var rotationRateYFilter: LowPassFilter
    var rotationRateZFilter: LowPassFilter
    var userAccelXFilter: LowPassFilter
    var userAccelYFilter: LowPassFilter
    var userAccelZFilter: LowPassFilter
    var gravityAccelXFilter: LowPassFilter
    var gravityAccelYFilter: LowPassFilter
    var gravityAccelZFilter: LowPassFilter
    var accelerationXFilter: LowPassFilter
    var accelerationYFilter: LowPassFilter
    var accelerationZFilter: LowPassFilter

    init(alpha: Double) {
        pitchFilter = LowPassFilter(alpha: alpha)
        yawFilter = LowPassFilter(alpha: alpha)
        rollFilter = LowPassFilter(alpha: alpha)
        rotationRateXFilter = LowPassFilter(alpha: alpha)
        rotationRateYFilter = LowPassFilter(alpha: alpha)
        rotationRateZFilter = LowPassFilter(alpha: alpha)
        userAccelXFilter = LowPassFilter(alpha: alpha)
        userAccelYFilter = LowPassFilter(alpha: alpha)
        userAccelZFilter = LowPassFilter(alpha: alpha)
        gravityAccelXFilter = LowPassFilter(alpha: alpha)
        gravityAccelYFilter = LowPassFilter(alpha: alpha)
        gravityAccelZFilter = LowPassFilter(alpha: alpha)
        accelerationXFilter = LowPassFilter(alpha: alpha)
        accelerationYFilter = LowPassFilter(alpha: alpha)
        accelerationZFilter = LowPassFilter(alpha: alpha)
    }

    func processData(_ data: SensorData) -> SensorData {
        var filteredData = data

        if let deviceMotion = data.deviceMotionData {
            let filteredDeviceMotion = DeviceMotionData(
                pitch: pitchFilter.filter(deviceMotion.pitch),
                yaw: yawFilter.filter(deviceMotion.yaw),
                roll: rollFilter.filter(deviceMotion.roll),
                rotationRateX: rotationRateXFilter.filter(deviceMotion.rotationRateX),
                rotationRateY: rotationRateYFilter.filter(deviceMotion.rotationRateY),
                rotationRateZ: rotationRateZFilter.filter(deviceMotion.rotationRateZ),
                userAccelX: userAccelXFilter.filter(deviceMotion.userAccelX),
                userAccelY: userAccelYFilter.filter(deviceMotion.userAccelY),
                userAccelZ: userAccelZFilter.filter(deviceMotion.userAccelZ),
                gravityAccelX: gravityAccelXFilter.filter(deviceMotion.gravityAccelX),
                gravityAccelY: gravityAccelYFilter.filter(deviceMotion.gravityAccelY),
                gravityAccelZ: gravityAccelZFilter.filter(deviceMotion.gravityAccelZ)
            )
            filteredData.deviceMotionData = filteredDeviceMotion
        }

        if let accelerometer = data.accelerometerData {
            let filteredAccelerometer = AccelerometerData(
                accelerationX: accelerationXFilter.filter(accelerometer.accelerationX),
                accelerationY: accelerationYFilter.filter(accelerometer.accelerationY),
                accelerationZ: accelerationZFilter.filter(accelerometer.accelerationZ)
            )
            filteredData.accelerometerData = filteredAccelerometer
        }

        return filteredData
    }
}
