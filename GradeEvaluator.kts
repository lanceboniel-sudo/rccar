package com.example.activityone

fun main() {

    val grades = listOf(85, 42, 70, 58, 90)

    for (grade in grades) {

        if (grade >= 60) {
        println("Grade:$grade, Remark: Pass")
    }
        else {
        println("Grade:$grade, Remark: Fail")
    }
    }
}
