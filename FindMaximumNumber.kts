package com.example.activityone

fun main(){
    val numbers = listOf(1,23,46,45,7,487,2,432,42,34234,2,424,24)
    var maxnumber = numbers[0]

    for(maximum in numbers){
        if(maximum > maxnumber){
            maxnumber = maximum
        }
    }
    println("The largest number is $maxnumber")
}
