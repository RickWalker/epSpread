import java.util.*;

/**
 * TweetFreqDataSource
 * Create test data for layout engine.
 *
 * @author Llyr
 */
public class TweetFreqDataSource implements DataSource {

  public Random rnd;

  public TweetFreqDataSource() {
    // seeded, so we can reproduce results
    this(2);
  }

  public TweetFreqDataSource(int seed) {
    rnd = new Random(seed);
  }

  public Layer[] make(int numLayers, int sizeArrayLength) {
    Layer[] layers = new Layer[numLayers];

    for (int l = 0; l < numLayers; l++) {
      String name   = "Layer #" + l;
      float[] size  = new float[sizeArrayLength];
      
      
      size = new float[sizeArrayLength];
      
      for(int j=0; j<sizeArrayLength; j++)
      {
      size[j] = 3;
      
      if(l == 0)
        size[3] = 8;
        
      }
     
      layers[l]     = new Layer(name, size);
    }

    return layers;
  }

  protected float[] makeRandomArray(int n) {
    float[] x = new float[n];

    // add a handful of random bumps
    for (int i=0; i<5; i++) {
      addRandomBump(x);
    }

    return x;
  }





  protected void addRandomBump(float[] x) {
    float height  = 1 / rnd.nextFloat();
    float cx      = (float)(2 * rnd.nextFloat() - 0.5);
    float r       = rnd.nextFloat() / 10;

    for (int i = 0; i < x.length; i++) {
      float a = (i / (float)x.length - cx) / r;
      //x[i] += height * Math.exp(-a * a);
      
     x[i] = 3;
    }
  }

}
