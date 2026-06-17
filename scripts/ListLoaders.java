// Lists Ghidra loader extension classes visible to headless mode.

import ghidra.app.script.GhidraScript;
import ghidra.app.util.opinion.Loader;
import ghidra.util.classfinder.ClassSearcher;

public class ListLoaders extends GhidraScript {
    @Override
    public void run() throws Exception {
        try {
            println("direct=" + Class.forName("xexloaderwv.XEXLoaderWVLoader").getName());
        }
        catch (Throwable t) {
            println("direct-load-failed=" + t.getClass().getName() + ":" + t.getMessage());
        }

        for (Class<? extends Loader> loaderClass : ClassSearcher.getClasses(Loader.class)) {
            println(loaderClass.getName());
        }
    }
}
