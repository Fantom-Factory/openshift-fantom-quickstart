using inet
using afBedSheet

class Main {
    Int main(Str[] args) {
    	port	:= args[0].toInt
    	ipAddr	:= IpAddr(args[1])
        return BedSheetBuilder(AppModule#.qname).setIpAddress(ipAddr).startWisp(port)
    }
}
