import java.net.*;
import java.io.*;
import java.util.Vector;
import java.util.HashMap;
import java.lang.Math;
import Jama.Matrix;

class Client {
    
    public static void main(String args[]) {
	
	try {
	    // data file name
	    String file_name;

	    // used for reading the data file
	    FileInputStream file_stream;
	    DataInputStream file_in;
	    BufferedReader file_br;
	    String file_line;
	    String[] line_tokens;

	    // data structures used to hold the client data read in from files
	    Vector< Vector<Double> > Xv = new Vector< Vector<Double> >();
	    Vector<Double> Yv = new Vector<Double>();
	    Vector<Double> xrow;

	    // data structures used to hold client data for matrix constructors
	    double[][] Xa;
	    double[] Ya;

	    // number of columns and rows in data file
	    int m = -1;
	    int n;

	    double epsilon = Math.pow(10.0, -6.0);
	    Matrix beta0;
	    Matrix beta1;
	    Matrix hat_beta;
	    Matrix cov_matrix, SD;
	    Matrix X, Y;
	    Matrix P, W, D, E;

	    // configuration file and accessing data structures
	    FileInputStream config_stream;
	    DataInputStream config_in;
	    BufferedReader config_br;
	    String config_line;
	    String[] line_contents;
	    HashMap<String, String> config;
	    String config_key, config_value;

	    // read configuration info. from file client_config
	    config_stream = new FileInputStream("client_config");
	    config_in = new DataInputStream(config_stream);
	    config_br = new BufferedReader(new InputStreamReader(config_in));

	    // read configuration information and populate hash map config
	    config = new HashMap<String, String>();
	    while ((config_line = config_br.readLine()) != null) {
		line_contents = config_line.split("=");
		config_key = line_contents[0].trim();
		config_value = line_contents[1].trim();
		config.put(config_key, config_value);
	    }

	    // host name and port number
	    String host = config.get("host");
	    int port = Integer.parseInt(config.get("port"));
	    Socket socket;

	    // input and output stream
	    DataInputStream in;
	    DataOutputStream out;

	    int i, j;

	    // count the number of iterations
	    int iter = 0;

	    // missing filename as argument
	    if (args.length < 1) {
		System.out.println("ERROR: Please provide the data file as " +
				   "an argument.");
		System.exit(-1);
	    }

	    file_name = args[0];
	    System.out.println("Using data file '" + file_name + "'.");

	    // access the file
	    file_stream = new FileInputStream(file_name);
	    file_in = new DataInputStream(file_stream);
	    file_br = new BufferedReader(new InputStreamReader(file_in));

	    // read file and populate X and Y matrices
	    n = 0;
        // get rid of the first line
        if ((file_line = file_br.readLine()) != null){
             // do nothing
        }
        else{
            System.out.println("Warning: no line is read...");
        }

	    while ((file_line = file_br.readLine()) != null) {
		// update number of rows
		n = n + 1;

		line_tokens = file_line.split(",");

		// detect number of columns in data file
		if (m == -1) {
		    m = line_tokens.length;
		}
		// line in data file does not match dimensions
		else if (m != line_tokens.length) {
		    System.out.println("ERROR: data file dimensions don't " +
				       "match on line " + n + ".");
		    System.exit(-1);
		}

		// populate data structures with data
		xrow = new Vector<Double>();
		xrow.add(1.0);
		for (i = 1; i < line_tokens.length; i++) {
		    xrow.add(new Double(line_tokens[i]));
		}
		Xv.add(xrow);
		Yv.add(new Double(line_tokens[0]));
	    }

	    // close input stream
	    file_in.close();

	    // connect to server and establish input and output streams
	    socket = new Socket(host, port);
	    System.out.println("Connected to '" + host + "' on port " + port +
			       ".");
	    in = new DataInputStream(socket.getInputStream());
	    out = new DataOutputStream(socket.getOutputStream());

	    // out.writeInt(888);

	    beta0 = new Matrix(m, 1, -1.0);
	    beta1 = new Matrix(m, 1, 0.0);
	    cov_matrix = new Matrix(m, m);

	    // convert data into arrays to be passed to Matrix's constructor
	    Xa = two_dim_vec_to_arr(Xv);
	    Ya = one_dim_vec_to_arr(Yv);

	    // create X and Y matrices
	    X = new Matrix(Xa);
	    Y = new Matrix(Ya, Ya.length);

	    // iteratively update beta1
	    while (max_abs((beta1.minus(beta0)).getArray()) > epsilon) {

		// if (iter == 2)
		//     break;

		System.out.println("value: " + max_abs((beta1
	            .minus(beta0)).getArray()));

		System.out.println("Iteration " + iter);

		beta0 = beta1.copy();

		// P <- 1 + exp(-x%*%beta0)
		P = (X.times(-1)).times(beta0);
		exp(P.getArray());
		add_one(P.getArray());
		div_one(P.getArray());

		// w = diag(c(p*(1-p)))
		W = P.copy();
		W.timesEquals(-1.0);
		add_one(W.getArray());
		W.arrayTimesEquals(P);
		W = W.transpose();
		W = diag(W.getArray()[0]);

		// d <- t(x)%*%w%*%x
		D = ((X.transpose()).times(W)).times(X);
		// e <- t(x)%*%(y-p)
		E = (X.transpose()).times(Y.plus(P.uminus()));

		// D.print(10,3);
		// E.print(10,3);

		// send D to server
		for (i = 0; i < m; i++) {
		    for (j = 0; j < m; j++) {
			out.writeDouble(D.get(i,j));
		    }
		}

		// send E to server
		for (i = 0; i < m; i++) {
		    out.writeDouble(E.get(i,0));
		}

		// receive beta1 from server
		for (i = 0; i < m; i++) {
		    beta1.set(i, 0, in.readDouble());
		}

		// print beta1 for this iteration
		beta1.print(8, 8);

		iter = iter + 1;
	    }

	    System.out.println("value on exit: " + max_abs((beta1
	            .minus(beta0)).getArray()));
	    System.out.println("Finished iteration.");

	    // compute variance-covariance-covariance matrix
	    hat_beta = beta1.copy();

	    P = (X.times(-1)).times(hat_beta);
	    exp(P.getArray());
	    add_one(P.getArray());
	    div_one(P.getArray());

	    W = P.copy();
	    W.timesEquals(-1.0);
	    add_one(W.getArray());
	    W.arrayTimesEquals(P);
	    W = W.transpose();
	    W = diag(W.getArray()[0]);

	    D = ((X.transpose()).times(W)).times(X);

	    // send D to server
	    for (i = 0; i < m; i++) {
		for (j = 0; j < m; j++) {
		    out.writeDouble(D.get(i,j));
		}
	    }

	    // read covariance matrix from server
	    for (i = 0; i < m; i++) {
		for (j = 0; j < m; j++) {
		    cov_matrix.set(i, j, in.readDouble());
		}
	    }

	    System.out.println("Covariance matrix:");
	    cov_matrix.print(8, 6);

	    // compute SD matrix
	    SD = new Matrix(1, m);
	    for (i = 0; i < m; i++) {
		SD.set(0, i, Math.sqrt(cov_matrix.get(i,i)));
	    }

	    System.out.println("SD matrix:");
	    SD.print(8, 6);

	}
	catch (Exception e) {
	    System.out.println(e);
	    System.exit(-1);
	}
    }

    /* Returns the absolute maximum of the elements in the two dimensional
       array matrix. */
    public static double max_abs(double[][] matrix) {
	int i,j;
	boolean set = false;
	double max = 0;

	// iterate through matrix
	for (i = 0; i < matrix.length; i++) {
	    for (j = 0; j < matrix[i].length; j++) {

		// maintain absolute max number found
		if (!set) {
		    max = Math.abs(matrix[i][j]);
		    set = true;
		}
		else if (Math.abs(matrix[i][j]) > max) {
		    max = Math.abs(matrix[i][j]);
		}
	    }
	}

	return max;
    }

    /* Convert a 2D vector of Doubles into a 2D array of doubles. */
    public static double[][] two_dim_vec_to_arr(Vector< Vector<Double> >V) {
	// allocate part of the array
	double[][] A = new double[V.size()][];
	int i;

	// allocate and convert rows of the vector
	for (i = 0; i < V.size(); i++) {
	    A[i] = one_dim_vec_to_arr(V.get(i));
	}

	// return 2D array
	return A;
    }

    /* Convert a Vector of Doubles into an array of doubles. */
    public static double[] one_dim_vec_to_arr(Vector<Double> V) {
	int size = V.size();
	int i;
	double[] A = new double[size];

	for (i = 0; i < size; i++) {
	    A[i] = (V.get(i)).doubleValue();
	}

	return A;
    }

    /* Set each element of the 2D double array to e^a where a is the value of
       an element. */
    public static void exp(double[][] A) {
	int i,j;
	for (i = 0; i < A.length; i++) {
	    for (j = 0; j < A[i].length; j++) {
		A[i][j] = Math.exp(A[i][j]);
	    }
	}
    }

    /* Set each element of the 2D double array to 1 + a where a is the value of
       an element. */
    public static void add_one(double[][] A) {
	int i,j;
	for (i = 0; i < A.length; i++) {
	    for (j = 0; j < A[i].length; j++) {
		A[i][j] = 1 + A[i][j];
	    }
	}
    }

    /* Set each element of the 2D double array to 1/a where a is the value of
       an element. */
    public static void div_one(double[][] A) {
	int i,j;
	for (i = 0; i < A.length; i++) {
	    for (j = 0; j < A[i].length; j++) {
		A[i][j] = 1.0 / A[i][j];
	    }
	}
    }

    /* Given an array of length n, returns an n by n matrix M where
       M[i][j] = A[i] if i = j and 0 otherwise. */
    public static Matrix diag(double[] A) {
	int n = A.length;
	int i;

	Matrix M = new Matrix(n, n, 0.0);
	for (i = 0; i < n; i++) {
	    M.set(i,i,A[i]);
	}
	return M;
    }
}
