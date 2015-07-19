# Author: Kevin Shah
# roll number: 131021
# Computer Networks - Lab Assignment 1
# semester 5
# Institute of Engineering and Technology, Ahmedabad University

#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 3 black

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam out.nam &
        exit 0
}

#Create 11 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

$n2 shape hexagon
$n7 shape hexagon
$n2 color blue 
$n7 color blue 

$n8 shape square
$n0 shape square
$n8 color red
$n0 color red 

#Create links between the nodes
$ns duplex-link $n0 $n1 1Mb 50ms DropTail
$ns duplex-link $n0 $n3 1Mb 50ms DropTail
$ns duplex-link $n1 $n2 1Mb 50ms DropTail
$ns duplex-link $n2 $n3 1Mb 50ms DropTail
$ns duplex-link $n4 $n5 1Mb 50ms DropTail
$ns duplex-link $n4 $n6 1Mb 50ms DropTail
$ns duplex-link $n5 $n6 1Mb 50ms DropTail
$ns duplex-link $n6 $n7 1Mb 50ms DropTail
$ns duplex-link $n6 $n8 1Mb 50ms DropTail
$ns duplex-link $n9 $n10 1Mb 50ms DropTail

#setting up LAN between nodes 2, 4 and 9
set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 50ms LL Queue/DropTail Mac/Csma/Cd Channel]

#Give node position (for NAM)
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient up
$ns duplex-link-op $n4 $n5 orient down
$ns duplex-link-op $n5 $n6 orient left
$ns duplex-link-op $n6 $n4 orient right
$ns duplex-link-op $n7 $n6 orient right-up
$ns duplex-link-op $n8 $n6 orient left-up
$ns duplex-link-op $n9 $n10 orient up
$ns duplex-link-op $n4 $n5 orient right-down

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Setup a TCP connection
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP


#Setup a UDP connection
set udp1 [new Agent/UDP]
$ns attach-agent $n8 $udp1
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp1 $null
$udp1 set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp1
$cbr set type_ CBR
$cbr set packet_size_ 100
$cbr set rate_ 0.1mb
$cbr set random_ false


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp $null
$udp set fid_ 3

#Setup a CBR over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.1mb
$cbr1 set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr start"
$ns at 1.5 "$cbr stop"

$ns at 1.5 "$cbr1 start"
$ns at 3.0 "$cbr1 stop"

$ns at 3.0 "$ftp start"
$ns at 4.0 "$ftp stop"

#Detach tcp and sink agents
$ns at 4.5 "$ns detach-agent $n2 $tcp ; $ns detach-agent $n7 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

#Run the simulation
$ns run
