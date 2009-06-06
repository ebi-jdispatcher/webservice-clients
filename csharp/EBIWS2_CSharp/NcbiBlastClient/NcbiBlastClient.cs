/* $Id$
 * ======================================================================
 * jDispatcher SOAP client for NCBI BLAST
 * ====================================================================== */
using System;
using System.IO;
using AbstractWsClient;
using NcbiBlastClient.EbiWS.NcbiBlast;

namespace EbiWS
{
	class NcbiBlastClient : AbstractWsClient.AbstractWsClient
	{
		/// <summary>Webservice proxy object</summary>
		public JDispatcherService SrvProxy {
			get{return srvProxy;}
			set{srvProxy = value;}
		}
		private JDispatcherService srvProxy = null;
		/// <summary>Parameters used for lanching jobs</summary>
		public InputParameters InParams {
			get{return inParams;}
			set{inParams = value;}
		}
		private InputParameters inParams = null;
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"NCBI BLAST
==========

Rapid sequence database search programs utilizing the BLAST algorithm

For more detailed help information refer to
http://www.ebi.ac.uk/Tools/blastall/help.html

[Required]

  -p, --program        : str  : BLAST program to use: see --paramDetail program
  -D, --database       : str  : database(s) to search, space seperated: see
                                --paramDetail database
      --stype          : str  : query sequence type
  seqFile              : file : query sequence (""-"" for STDIN)

[Optional]

  -m, --matrix         : str  : scoring matrix, see --paramDetail matrix
  -e, --exp            : real : 0<E<= 1000. Statistical significance threshold
                                for reporting database sequence matches.
  -f, --filter         :      : low complexity sequence filter, see
                                --paramDetail filter
  -A, --align          : int  : alignment format, see --paramDetail align
  -s, --scores         : int  : maximum number of scores to report
  -n, --alignments     : int  : maximum number of alignments to report
  -u, --match          : int  : score for a match (BLASTN only)
  -v, --mismatch       : int  : score for a missmatch (BLASTN only)
  -o, --gapopen        : int  : gap open penalty
  -x, --gapext         : int  : gap extension penalty
  -d, --dropoff        : int  : drop-off score
  -g, --gapalign       :      : optimise gapped alignments
      --seqrange       : str  : region in query sequence to use for search
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			NcbiBlastClient wsApp = new NcbiBlastClient();
			// If no arguments print usage and return
			if (args.Length < 1)
			{
				wsApp.PrintUsageMessage();
				return retVal;
			}
			try {
				// Parse the command line
				wsApp.ParseCommand(args);
				// Perform the selected action
				switch (wsApp.Action)
				{
					case "paramList": // List parameter names
						wsApp.PrintParams();
						break;
					case "paramDetail": // Parameter detail
						wsApp.PrintParamDetail(wsApp.ParamName);
						break;
					case "submit": // Submit a job
						wsApp.SubmitJob();
						break;
					case "status": // Get job status
						wsApp.PrintStatus();
						break;
					case "resultTypes": // Get result types
						wsApp.PrintResultTypes();
						break;
					case "polljob": // Get job results
						wsApp.GetResults();
						break;
					case "getids": // Get IDs from job result
						wsApp.PrintGetIds();
						break;
					case "help": // Do help
						wsApp.PrintUsageMessage();
						break;
					default: // Any other action.
						Console.WriteLine("Error: unknown action " + wsApp.Action);
						retVal = 1;
						break;
				}
			}
			catch(System.Exception ex) { // Catch all exceptions
				Console.Error.WriteLine("Error: " + ex.Message);
				Console.Error.WriteLine(ex.StackTrace);
				retVal = 2;
			}
			return retVal;
		}
		
		/// <summary>
		/// Print the usage message.
		/// </summary>
		private void PrintUsageMessage()
		{
			PrintDebugMessage("PrintUsageMessage", "Begin", 1);
			Console.WriteLine(usageMsg);
			PrintGenericOptsUsage();
			PrintDebugMessage("PrintUsageMessage", "End", 1);
		}
		
		/// <summary>Parse command-line options</summary>
		/// <param name="args">Command-line options</param>
		private void ParseCommand(string[] args)
		{
			PrintDebugMessage("ParseCommand", "Begin", 1);
			InParams = new InputParameters();
			// Force default values
			InParams.stype = "protein";
			InParams.program = null;
			InParams.database = null;
			InParams.matrix = null;
			InParams.exp = "10";
			InParams.alignments = 50;
			InParams.scores = 50;
			InParams.filter = "F";
			InParams.seqrange = null;
			for (int i = 0; i < args.Length; i++)
			{
				PrintDebugMessage("parseCommand", "arg: " + args[i], 2);
				switch (args[i])
				{
						// Generic options
					case "--help": // Usage info
						Action = "help";
						break;
					case "-h":
						goto case "--help";
					case "/help":
						goto case "--help";
					case "/h":
						goto case "--help";
					case "--params": // List input parameters
						Action = "paramList";
						break;
					case "/params":
						goto case "--params";
					case "--paramDetail": // Parameter details
						ParamName = args[++i];
						Action = "paramDetail";
						break;
					case "/paramDetail":
						goto case "--paramDetail";
					case "--jobid": // Job Id to get status or results
						JobId = args[++i];
						break;
					case "/jobid":
						goto case "--jobid";
					case "--status": // Get job status
						Action = "status";
						break;
					case "/status":
						goto case "--status";
					case "--resultTypes": // Get result types
						Action = "resultTypes";
						break;
					case "/resultTypes":
						goto case "--resultTypes";
					case "--polljob": // Get results for job
						Action = "polljob";
						break;
					case "/polljob":
						goto case "--polljob";
					case "--outfile": // Base name for results file(s)
						OutFile = args[++i];
						break;
					case "/outfile":
						goto case "--outfile";
					case "--outformat": // Only save results of this format
						OutFormat = args[++i];
						break;
					case "/outformat":
						goto case "--outformat";
					case "--ids": // Get entry IDs from result
						Action = "getids";
						break;
					case "/ids":
						goto case "--ids";
					case "--verbose": // Output level
						OutputLevel++;
						break;
					case "/verbose":
						goto case "--verbose";
					case "--quiet": // Output level
						OutputLevel--;
						break;
					case "/quiet":
						goto case "--quiet";
					case "--email": // User e-mail address
						Email = args[++i];
						break;
					case "/email":
						goto case "--email";
					case "--title": // Job title
						JobTitle = args[++i];
						break;
					case "/title":
						goto case "--title";
					case "--async": // Async submission
						Action = "submit";
						break;
					case "/async":
						goto case "--async";
					case "--debugLevel":
						DebugLevel = Convert.ToInt32(args[++i]);
						break;
					case "/debugLevel":
						goto case "--debugLevel";
						
						// Tool specific options
					case "--program": // BLAST program
						InParams.program = args[++i];
						Action = "submit";
						break;
					case "-p":
						goto case "--program";
					case "/program":
						goto case "--program";
					case "/p":
						goto case "--program";
					case "--database": // Database to search
						char[] sepList = { ' ', ',' };
						InParams.database = args[++i].Split(sepList);
						Action = "submit";
						break;
					case "-D":
						goto case "--database";
					case "/database":
						goto case "--database";
					case "/D":
						goto case "--database";
					case "--matrix": // Scoring matrix
						InParams.matrix = args[++i];
						Action = "submit";
						break;
					case "-m":
						goto case "--matrix";
					case "/matrix":
						goto case "--matrix";
					case "/m":
						goto case "--matrix";
					case "--exp": // E-value threshold
						InParams.exp = args[++i];
						Action = "submit";
						break;
					case "-E":
						goto case "--exp";
					case "/exp":
						goto case "--exp";
					case "/E":
						goto case "--exp";
					case "--filter": // Low complexity filter
						InParams.filter = "1"; // Set true
						Action = "submit";
						break;
					case "-f":
						goto case "--filter";
					case "/filter":
						goto case "--filter";
					case "/f":
						goto case "--filter";
					case "--align": // Alignment format
						InParams.align = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "/align":
						goto case "--align";
					case "--scores": // Maximum number of scores to report
						InParams.scores = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "-s":
						goto case "--scores";
					case "/scores":
						goto case "--scores";
					case "/s":
						goto case "--scores";
					case "--alignments": // Maximum number of alignments to report
						InParams.alignments = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "/alignments":
						goto case "--alignments";
					case "--numal":
						goto case "--alignments";
					case "/numal":
						goto case "--alignments";
					case "-n":
						goto case "--alignments";
					case "/n":
						goto case "--alignments";
					case "--dropoff": // Drop-off score
						InParams.dropoff = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "-d":
						goto case "--dropoff";
					case "/dropoff":
						goto case "--dropoff";
					case "/d":
						goto case "--dropoff";
					case "--opengap": // Gap open penalty
						InParams.gapopen = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "-o":
						goto case "--opengap";
					case "/opengap":
						goto case "--opengap";
					case "/o":
						goto case "--opengap";
					case "--extendgap": // Gap extension penalty
						InParams.gapext = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "-e":
						goto case "--extendgap";
					case "/extendgap":
						goto case "--extendgap";
					case "/e":
						goto case "--extendgap";
					case "--gapalign": // Use gapped alignments
						InParams.gapalign = true;
						Action = "submit";
						break;
					case "-g":
						goto case "--gapalign";
					case "/gapalign":
						goto case "--gapalign";
					case "/g":
						goto case "--gapalign";
						
						// Input data/sequence option
					case "--sequence": // Input sequence
						i++;
						goto default;
					default:
						// Check for unknown option
						if (args[i].StartsWith("--") || args[i].LastIndexOf('/') == 0)
						{
							Console.Error.WriteLine("Error: unknown option: " + args[i] + "\n");
							Action = "exit";
							return;
						}
						// Must be data argument
						InParams.sequence = LoadData(args[i]);
						Action = "submit";
						break;
				}
			}
			PrintDebugMessage("ParseCommand", "End", 1);
		}
		
		protected override void ServiceProxyConnect()
		{
			PrintDebugMessage("ServiceProxyConnect", "Begin", 11);
			if (SrvProxy == null) SrvProxy = new JDispatcherService();
			PrintDebugMessage("ServiceProxyConnect", "End", 11);
		}
		
		public override string[] GetParams()
		{
			PrintDebugMessage("GetParams", "Begin", 1);
			ServiceProxyConnect();
			MessageGetParameters req = new MessageGetParameters();
			MessageGetParametersResponse res = SrvProxy.getParameters(req);
			string[] paramNameList = res.parameters;
			PrintDebugMessage("GetParams", "got " + paramNameList.Length + " parameter names", 2);
			PrintDebugMessage("GetParams", "End", 1);
			return paramNameList;
		}
		
		public wsParameterDetails GetParamDetail(string paramName)
		{
			PrintDebugMessage("GetParamDetail", "Begin", 1);
			PrintDebugMessage("GetParamDetail", "paramName: " + paramName, 2);
			MessageGetParameterDetails req = new MessageGetParameterDetails();
			req.parameterId = paramName;
			MessageGetParameterDetailsResponse res = SrvProxy.getParameterDetails(req);
			wsParameterDetails paramDetail = res.parameterDetails;
			PrintDebugMessage("GetParamDetail", "End", 1);
			return paramDetail;
		}
		
		protected override void PrintParamDetail(string paramName)
		{
			PrintDebugMessage("PrintParamDetail", "Begin", 1);
			wsParameterDetails paramDetail = GetParamDetail(paramName);
			Console.WriteLine("{0}\t{1}", paramDetail.name, paramDetail.type);
			if (paramDetail.description != null) Console.WriteLine(paramDetail.description);
			foreach (wsParameterValue paramValue in paramDetail.values)
			{
				Console.Write(paramValue.value);
				if (paramValue.defaultValue) Console.Write("\tdefault");
				Console.WriteLine();
				if (paramValue.label != null) Console.WriteLine("\t{0}", paramValue.label);
				foreach (wsProperty valueProperty in paramValue.properties)
				{
					Console.WriteLine("\t{0}\t{1}", valueProperty.key, valueProperty.value);
				}
			}
			PrintDebugMessage("PrintParamDetail", "End", 1);
		}
		
		/// <summary>Submit a job to the service</summary>
		public override void SubmitJob()
		{
			PrintDebugMessage("SubmitJob", "Begin", 1);
			JobId = RunApp(Email, JobTitle, InParams);
			if (OutputLevel > 0 || Async) Console.WriteLine(JobId);
			// Simulate sync mode
			if (!Async) GetResults();
			PrintDebugMessage("SubmitJob", "End", 1);
		}
		
		/// <summary>Submit a job to the service</summary>
		/// <param name="input">Structure describing the input parameters</param>
		/// <param name="content">Structure containing the input data</param>
		/// <returns>A string containing the job identifier</returns>
		public string RunApp(string email, string title, InputParameters input)
		{
			PrintDebugMessage("RunApp", "Begin", 1);
			PrintDebugMessage("RunApp", "email: " + email, 2);
			PrintDebugMessage("RunApp", "title: " + title, 2);
			PrintDebugMessage("RunApp", "input:\n" + ObjectFieldsToString(input) + ObjectPropertiesToString(input), 2);
			string jobId = null;
			this.ServiceProxyConnect(); // Ensure we have a service proxy
			// Submit the job
			MessageRun req = new MessageRun();
			req.email = Email;
			req.title = JobTitle;
			req.parameters = input;
			MessageRunResponse res = SrvProxy.run(req);
			jobId = res.jobId;
			PrintDebugMessage("RunApp", "jobId: " + jobId, 2);
			PrintDebugMessage("RunApp", "End", 1);
			return jobId;
		}
		
		/// <summary>Get the job status</summary>
		/// <param name="jobId">Job identifier to get the status of.</param>
		/// <returns>A string describing the status</returns>
		public override string GetStatus(string jobId)
		{
			PrintDebugMessage("GetStatus", "Begin", 1);
			string status = "PENDING";
			this.ServiceProxyConnect(); // Ensure we have a service proxy
			MessageGetStatus req = new MessageGetStatus();
			req.jobId = jobId;
			MessageGetStatusResponse res = SrvProxy.getStatus(req);
			status = res.status;
			PrintDebugMessage("GetStatus", "status: " + status, 2);
			PrintDebugMessage("GetStatus", "End", 1);
			return status;
		}
		
		public wsResultType[] GetResultTypes(string jobId)
		{
			PrintDebugMessage("GetResultTypes", "Begin", 2);
			MessageGetResultTypes req = new MessageGetResultTypes();
			req.jobId = jobId;
			MessageGetResultTypesResponse res = SrvProxy.getResultTypes(req);
			wsResultType[] resultTypes = res.resultTypes;
			PrintDebugMessage("GetResultTypes", "End", 2);
			return resultTypes;
		}
		
		/// <summary>Print a summary of the result types for a job</summary>
		public override void PrintResultTypes()
		{
			PrintDebugMessage("PrintResultTypes", "Begin", 1);
			PrintDebugMessage("PrintResultTypes", "JobId: " + JobId, 2);
			this.ServiceProxyConnect(); // Ensure we have a service proxy
			wsResultType[] resultTypes = GetResultTypes(JobId);
			PrintDebugMessage("PrintResultTypes", "resultTypes: " + resultTypes.Length, 2);
			PrintProgressMessage("Getting output formats for job " + JobId, 1);
			if (OutputLevel > 0)
			{
				Console.WriteLine("Type\tExtension\n==============================");
			}
			foreach (wsResultType resultType in resultTypes)
			{
				Console.WriteLine(resultType.identifier + "\t" + resultType.fileSuffix);
			}
			PrintDebugMessage("PrintResultTypes", "End", 1);
		}
		
		public byte[] GetResult(string jobId, string format)
		{
			PrintDebugMessage("GetResult", "Begin", 1);
			PrintDebugMessage("GetResult", "jobId: " + jobId, 1);
			PrintDebugMessage("GetResult", "format: " + format, 1);
			byte[] result = null;
			MessageGetResult req = new MessageGetResult();
			req.jobId = jobId;
			req.type = format;
			MessageGetResultResponse res = SrvProxy.getResult(req);
			result = res.output;
			PrintDebugMessage("GetResult", "End", 1);
			return result;
		}
		
		/// <summary>Get the job results</summary>
		/// <param name="jobId">Job identifier to get the results from.</param>
		/// <param name="outformat">Selected output format or null for all formats.</param>
		/// <param name="outFileBase">Basename for the output file. If null the jobId will be used.</param>
		public override void GetResults(string jobId, string outformat, string outFileBase)
		{
			PrintDebugMessage("GetResults", "Begin", 1);
			PrintDebugMessage("GetResults", "jobId: " + jobId, 2);
			PrintDebugMessage("GetResults", "outformat: " + outformat, 2);
			PrintDebugMessage("GetResults", "outFileBase: " + outFileBase, 2);
			this.ServiceProxyConnect(); // Ensure we have a service proxy
			// Check status, and wait if not finished
			ClientPoll(jobId);
			// Use JobId if output file name is not defined
			if (outFileBase == null) OutFile = jobId;
			else OutFile = outFileBase;
			// Get list of data types
			wsResultType[] resultTypes = GetResultTypes(jobId);
			PrintDebugMessage("GetResults", "resultTypes: " + resultTypes.Length + " available", 2);
			// Get the data and write it to a file
			Byte[] res = null;
			if (outformat != null)
			{ // Specified data type
				wsResultType selResultType = null;
				foreach (wsResultType resultType in resultTypes)
				{
					if (resultType.identifier == outformat) selResultType = resultType;
				}
				PrintDebugMessage("GetResults", "resultType:\n" + ObjectFieldsToString(selResultType), 2);
				res = GetResult(jobId, selResultType.identifier);
				if (OutFile == "-") WriteFile(OutFile, res);
				else WriteFile(OutFile + "." + selResultType.fileSuffix, res);
			}
			else
			{ // Data types available
				// Write a file for each output type
				foreach (wsResultType resultType in resultTypes)
				{
					PrintDebugMessage("GetResults", "resultType:\n" + ObjectFieldsToString(resultType), 2);
					res = GetResult(jobId, resultType.identifier);
					if (OutFile == "-") WriteFile(OutFile, res);
					else WriteFile(OutFile + "." + resultType.fileSuffix, res);
				}
			}
			PrintDebugMessage("GetResults", "End", 1);
		}
		
		/// <summary>Get entry Ids from job result</summary>
		/// <param name="jobId">Job identifer for result to get Ids from</param>
		/// <results>List of entry Ids as a string array</results>
		public string[] GetIds(string jobId)
		{
			PrintDebugMessage("GetIds", "Begin", 1);
			PrintDebugMessage("GetIds", "jobId: " + jobId, 2);
			string[] retVal = null;
			this.ServiceProxyConnect(); // Ensure we have a service proxy
			// Check status, and wait if not finished
			ClientPoll(jobId);
			// Get the Ids
			byte[] content = GetResult(jobId, "ids");
			System.Text.ASCIIEncoding enc = new System.Text.ASCIIEncoding();
			String tempStr = enc.GetString(content);
			char[] sepList = { '\n' };
			retVal = tempStr.Split(sepList);
			PrintDebugMessage("GetIds", "got " + retVal.Length + " Ids", 2);
			PrintDebugMessage("GetIds", "End", 1);
			return retVal;
		}
		
		/// <summary>Print entry Ids from job result</summary>
		/// <param name="jobId">Job identifer for result to get Ids from</param>
		public void PrintGetIds()
		{
			PrintDebugMessage("PrintGetIds", "Begin", 1);
			PrintDebugMessage("PrintGetIds", "JobId: " + JobId, 2);
			string[] idList = GetIds(JobId);
			foreach (string id in idList) Console.WriteLine(id);
			PrintDebugMessage("PrintGetIds", "End", 1);
		}
	}
}
