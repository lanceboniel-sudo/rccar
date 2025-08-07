package com.example.activityone

fun main(){

    val numbers = 1..20
    val evenNumbers = numbers.filter{it % 2 == 0}
    println("Filtered numbers $evenNumbers")
    val doubledNumber = evenNumbers.map{it * 2}
    println("Even numbers when doubled $doubledNumber")
}
