using afIoc
using afBedSheet

class AppModule {
    @Contribute { serviceType=FileHandler# }
    static Void contributeFileHandler(Configuration conf) {
        conf[`/`] = `html/`
    }
}
