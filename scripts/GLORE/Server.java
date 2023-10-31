import java.net.*;
import java.util.HashMap;
import java.util.concurrent.*;
import java.io.*;
import java.time.Duration;
import java.time.Instant;
import Jama.Matrix;

class Server implements Runnable {

    // socket connection and thread id
    private Socket m_socket;
    private int m_thread_id;
    private DataOutputStream m_out;
    private DataInputStream m_in;

    // number of participating clients
    static int num_clients;
    // memory used for storing client data
    static double[][][] D;
    static double[][] E;
    // semaphore used to ensure all clients send data before computation occurs
    static Semaphore data_lock;
    // semaphore used to ensure all client threads wait before sending beta1
    static Semaphore beta_lock;
    // semaphore used to ensure clients send var. cov. matrices
    static Semaphore var_cov_lock;
    // semaphore used to ensure client threads wait for var. cov. matrix comp.
    static Semaphore var_cov_comp_lock;
    // number of features in the data
    static int m;
    static double epsilon = Math.pow(10.0, -6.0);
    static Matrix beta0, beta1, cov_matrix;
    // count the number of iterations
    static int iter;

    private static class Computation implements Runnable {
	public void run() {
	    try {
		int i;
		Matrix temp_a, temp_b, temp_c;
		Matrix SD;

		iter = 0;

		// init beta vectors
		beta0 = new Matrix(m, 1, -1.0);
		beta1 = new Matrix(m, 1, 0.0);

		Instant start = Instant.now();
		// iteratively update beta1
		while (max_abs((beta1.minus(beta0)).getArray()) > epsilon) {

		    // if (iter == 2)
		    // 	break;

		    System.out.println("value: " + max_abs((beta1.minus(beta0))
							   .getArray()));

		    // wait for all clients to write data
		    for (i = 0; i < num_clients; i++) {
			data_lock.acquire();
		    }
		    System.out.println("comp: client data available for " +
				       "iter " + iter);

		    System.out.println("Iteration " + iter);

		    beta0 = beta1.copy();

		    /* beta1<-beta0+solve(rowSums(d,dims=2)+
		       diag(0.0000001,m))%*%(rowSums(e,dims=2)) */
		    temp_a = new Matrix(row_sums(E));
		    temp_b = new Matrix(row_sums(D));
		    temp_c = diag(0.0000001, m);

		    temp_b = temp_b.plus(temp_c);
		    temp_b = temp_b.inverse();
		    temp_b = temp_b.times(temp_a);
		    beta1 = beta0.plus(temp_b);

		    beta1.print(10,12);
		
		    System.out.println("comp: releasing beta1 lock for iter " +
				       iter);
		    // indicate to threads that beta1 is available
		    for (i = 0; i < num_clients; i++) {
			beta_lock.release();
		    }
		    iter = iter + 1;
		}

        Instant end = Instant.now();
        Duration totalTrainingTime = Duration.between(start, end);
        System.out.println("Total training time: " + totalTrainingTime.toMillis() / 1000.0 + "s");

		System.out.println("value on exit: " + max_abs((beta1
		        .minus(beta0)).getArray()));

		// wait for clients to send D matrices
		for (i = 0; i < num_clients; i++) {
		    var_cov_lock.acquire();
		}

		// compute covariance matrix
		temp_b = new Matrix(row_sums(D));
		temp_c = diag(0.0000001, m);

		temp_b = temp_b.plus(temp_c);
		cov_matrix = temp_b.inverse();

		System.out.println("Covariance matrix:");
		cov_matrix.print(8,6);

		// compute SD matrix
		SD = new Matrix(1, m);
		for (i = 0; i < m; i++) {
		    SD.set(0,i, Math.sqrt(cov_matrix.get(i,i)));
		}

		System.out.println("SD matrix:");
		SD.print(8,6);

		// signal client threads that the SD matrix is ready
		for (i = 0; i < num_clients; i++) {
		    var_cov_comp_lock.release();
		}

		System.out.println("Computation thread exiting.");
	    }
	    catch (Exception e) {
		System.out.println(e);
		System.exit(-1);
	    }
	}
	
	/* Return a one dimensional array that is the sum of the E.length
	   one dimensional vectors. */
	private double[][] row_sums(double[][] E) {

	    int i, j;
	    double [][] sums;
	    sums = new double[m][1];

	    // init sums
	    for (i = 0; i < m; i++) {
		sums[i][0] = 0.0;
	    }
	    // for each client, add its contribution to sums
	    for (i = 0; i < num_clients; i++) {
		for (j = 0; j < m; j++) {
		    sums[j][0] = sums[j][0] + E[i][j];
		}
	    }
	    return sums;
	}

	private double[][] row_sums(double[][][] E) {

	    int i,j,k;
	    double[][] sums;
	    sums = new double[m][m];
	    // init sums
	    for (i = 0; i < m; i++) {
		for (j = 0; j < m; j++) {
		    sums[i][j] = 0;
		}
	    }
	    // for each client, add its contribution to sums
	    for (i = 0; i < num_clients; i++) {
		for (j = 0; j < m; j++) {
		    for (k = 0; k < m; k++) {
			sums[j][k] = sums[j][k] + D[i][j][k];
		    }
		}
	    }
	    return sums;
	}

	/* Returns an n by n matrix where the diagonal entries are v and the
	   other entries are 0 */
	private Matrix diag(double v, int n) {
	    int i;
	    double[][] A = new double[n][n];
	    for (i = 0; i < n; i++) {
		A[i][i] = v;
	    }
	    return new Matrix(A);
	}
    }

    public static void main(String[] args) {

	try {
	    int i;
	    ServerSocket server_socket;
	    Socket connection = null;

	    // configuration file and accessing data structures
	    FileInputStream config_stream;
	    DataInputStream config_in;
	    BufferedReader config_br;
	    String config_line;
	    String[] line_contents;
	    HashMap<String, String> config;
	    String config_key, config_value;

	    // read configuration info. from file client_config
	    config_stream = new FileInputStream("server_config");
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

	    // set the number of participating clients
	    num_clients = Integer.parseInt(config.get("clients"));
	    // set number of features in the data
	    m = Integer.parseInt(config.get("features"));

	    // allocate memory for the client's data
	    D = new double[num_clients][m][m];
	    E = new double[num_clients][m];

	    // init data semaphore used to ensure all client data has arrived
	    data_lock = new Semaphore(num_clients);
	    for (i = 0; i < num_clients; i++) {
		data_lock.acquire();
	    }

	    /* init beta semaphore to block threads from sending beta before
	       the computation thread finishes computing it */
	    beta_lock = new Semaphore(num_clients);
	    for (i = 0; i < num_clients; i++) {
		beta_lock.acquire();
	    }

	    /* init variance covariance semaphore used to ensure variance
	       covariance matrices have arrived from clients */
	    var_cov_lock = new Semaphore(num_clients);
	    for (i = 0; i < num_clients; i++) {
		var_cov_lock.acquire();
	    }

	    /* init variance covariance computation semaphore to block threads
	       from sending matrix until computation thread is done */
	    var_cov_comp_lock = new Semaphore(num_clients);
	    for (i = 0; i < num_clients; i++) {
		var_cov_comp_lock.acquire();
	    }

	    // spawn computational thread
	    (new Thread(new Computation())).start();
	    
	    // connect each client, then spawn a thread for each client
	    server_socket = new 
		ServerSocket(Integer.parseInt(config.get("socket")));
	    for (i = 0; i < num_clients; i++) {
		connection = server_socket.accept();
		(new Thread(new Server(connection, i))).start();
	    }

	    System.out.println("Main thread exiting.");
	}
	catch(Exception e) {
	    System.out.println(e);
	    System.exit(-1);
	}
    }

    Server(Socket socket, int thread_id) {
	try {
	    // seat socket connection and thread id
	    m_socket = socket;
	    m_thread_id = thread_id;

	    m_out = new DataOutputStream(m_socket.getOutputStream());
	    m_in = new DataInputStream(m_socket.getInputStream());
	}
	catch (Exception e) {
	    System.out.println("ERROR: Exception occured in Server's " +
			       "constructor.");
	    System.exit(-1);
	}
    }

    public void run() {
	try {
	    int i, j;
	    int iter = 0;

	    // read data from clients and send beta to clients
	    while (max_abs((beta1.minus(beta0)).getArray()) > epsilon) {
		
		// if (iter == 2)
		//     break;

		// read D from client
		for (i = 0; i < m; i++) {
		    for (j = 0; j < m; j++) {
			D[m_thread_id][i][j] = m_in.readDouble();
		    }
		}
		// read E from client
		for (i = 0; i < m; i++) {
		    E[m_thread_id][i] = m_in.readDouble();
		}
		// release lock, indicating data is ready from this thread
		System.out.println(m_thread_id + ": releasing " +
				   "data lock for iter " + iter);
		data_lock.release();
		// wait for computation thread to finish computing beta1
		beta_lock.acquire();
		System.out.println(m_thread_id + ": sending beta1 " +
				   "for iter " + iter);

		// send beta1 to clients
		for (i = 0; i < m; i++) {
		    m_out.writeDouble(beta1.get(i,0));
		}
		
		iter = iter + 1;
	    }

	    // receive variance covariance matrix from client
	    for (i = 0; i < m; i++) {
		for (j = 0; j < m; j++) {
		    D[m_thread_id][i][j] = m_in.readDouble();
		}
	    }

	    // signal the computation thread: this client's data has arrived
	    var_cov_lock.release();

	    // wait for computation thread to finish computing SD matrix
	    var_cov_comp_lock.acquire();

	    // send covariance matrix to client
	    for (i = 0; i < m; i++) {
		for (j = 0; j < m; j++) {
		    m_out.writeDouble(cov_matrix.get(i,j));
		}
	    }

	    System.out.println("Thread " + m_thread_id + " exiting.");
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
}
