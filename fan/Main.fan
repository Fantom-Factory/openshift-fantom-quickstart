using inet
using afBedSheet

class Main {
    Int main(Str[] args) {
        BedSheetBuilder(AppModule#.qname)
        	.setIpAddress(IpAddr(args[1]))
        	.startWisp(args[0].toInt)
    }
}
