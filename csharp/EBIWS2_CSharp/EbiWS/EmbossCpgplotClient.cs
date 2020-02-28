/* $Id$
 * ======================================================================
 * 
 * Copyright 2011-2018 EMBL - European Bioinformatics Institute
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * ======================================================================
 * JDispatcher EMBOSS cpgplot (SOAP) client.
 *
 * See:
 * http://www.ebi.ac.uk/Tools/webservices/services/psa/emboss_cpgplot_soap
 * http://www.ebi.ac.uk/Tools/webservices/tutorials/csharp
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.EmbossCpgplotWs; // "Web Reference" or wsdl.exe generated stubs.

namespace EbiWS
{
	/// <summary>
	/// Client for EMBL-EBI EMBOSS cpgplot (SOAP) web service.
	/// </summary>	
	public class EmbossCpgplotClient : EbiWS.AbstractWsClient
	{
		/// <summary>Webservice proxy object</summary>
		public JDispatcherService SrvProxy
		{
			get { return srvProxy; }
			set { srvProxy = value; }
		}
		private JDispatcherService srvProxy = null;
		/// <summary>Parameters used for launching jobs</summary>
		public InputParameters InParams
		{
			get { return inParams; }
			set { inParams = value; }
		}
		private InputParameters inParams = null;
		/// <summary>Multiple fasta formatted sequences as input.</summary>
		protected Boolean multifasta = false;
		// Client object revision.
		private string revision = "$Revision$";
		
		// Default constructor. Required for abstract class constructor.
		public EmbossCpgplotClient()
		{
		}
		
		// Implementation of abstract method (AbsractWsClient.ServiceProxyConnect()).
		protected override void ServiceProxyConnect()
		{
			PrintDebugMessage("ServiceProxyConnect", "Begin", 11);
			if (SrvProxy == null) {
				SrvProxy = new JDispatcherService();
				SetProxyEndPoint(); // Set explicit service endpoint, if defined.
				SetProxyUserAgent(); // Set user-agent for client.
				// Enable HTTP response compression (MS .NET 2.0 or Mono 2.4.1 onward).
				SrvProxy.EnableDecompression = true;
			}
			PrintDebugMessage("ServiceProxyConnect", "SrvProxy: " + SrvProxy.ToString(), 12);
			PrintDebugMessage("ServiceProxyConnect", "End", 11);
		}
		
		// Set service proxy endpoint.
		private void SetProxyEndPoint() {
			PrintDebugMessage("SetProxyEndPoint", "Begin", 11);
			if(ServiceEndPoint != null && ServiceEndPoint.Length > 0) {
				SrvProxy.Url = ServiceEndPoint;
			}
			ServiceEndPoint = SrvProxy.Url;
			PrintDebugMessage("SetProxyEndPoint", "Service endpoint: " + SrvProxy.Url, 12);
			PrintDebugMessage("SetProxyEndPoint", "End", 11);
		}

		// Set User-agent for web service proxy.
		private void SetProxyUserAgent() {
			PrintDebugMessage("SetProxyUserAgent", "Begin", 11);
			String userAgent = ConstuctUserAgentStr(revision, this.GetType().Name, SrvProxy.UserAgent);
			PrintDebugMessage("SetProxyUserAgent", "userAgent: " + userAgent, 12);
			SrvProxy.UserAgent = userAgent;
			PrintDebugMessage("SetProxyUserAgent", "End", 11);
		}
		
		// Implementation of abstract method (AbsractWsClient.GetParams()).
		public override string[] GetParams()
		{
			PrintDebugMessage("GetParams", "Begin", 1);
			ServiceProxyConnect();
			string[] paramNameList = SrvProxy.getParameters();
			PrintDebugMessage("GetParams", "got " + paramNameList.Length + " parameter names", 2);
			PrintDebugMessage("GetParams", "End", 1);
			return paramNameList;
		}

		/// <summary>
		/// Get detailed information about a named parameter. 
		/// </summary>
		/// <param name="paramName">Name of the parameter to get the detailed description of.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>Object describing the parameter.
		/// A <see cref="wsParameterDetails"/>
		/// </returns>
		public wsParameterDetails GetParamDetail(string paramName)
		{
			PrintDebugMessage("GetParamDetail", "Begin", 1);
			PrintDebugMessage("GetParamDetail", "paramName: " + paramName, 2);
			ServiceProxyConnect();
			wsParameterDetails paramDetail = SrvProxy.getParameterDetails(paramName);
			PrintDebugMessage("GetParamDetail", "End", 1);
			return paramDetail;
		}

		// Implementation of abstract method (AbsractWsClient.PrintParammDetail()).
		protected override void PrintParamDetail(string paramName)
		{
			PrintDebugMessage("PrintParamDetail", "Begin", 1);
			wsParameterDetails paramDetail = GetParamDetail(paramName);
			Console.WriteLine("{0}\t{1}", paramDetail.name, paramDetail.type);
			if (paramDetail.description != null) Console.WriteLine(paramDetail.description);
			if (paramDetail.values != null)
			{
				foreach (wsParameterValue paramValue in paramDetail.values)
				{
					Console.Write(paramValue.value);
					if (paramValue.defaultValue) Console.Write("\tdefault");
					Console.WriteLine();
					if (paramValue.label != null) Console.WriteLine("\t{0}", paramValue.label);
					if (paramValue.properties != null)
					{
						foreach (wsProperty valueProperty in paramValue.properties)
						{
							Console.WriteLine("\t{0}\t{1}", valueProperty.key, valueProperty.value);
						}
					}
				}
			}
			PrintDebugMessage("PrintParamDetail", "End", 1);
		}

		/// <summary>Submit job(s) to the service.</summary>
		protected void SubmitJobs() {
			PrintDebugMessage("SubmitJobs", "Begin", 1);
			// Three modes...
			// 1. Multiple fasta sequence input.
			if(this.multifasta) {
				SetSequenceFile(InParams.sequence);
				string inSeq = null;
				while((inSeq = NextSequence()) != null) {
					InParams.sequence = inSeq;
					SubmitJob();
				}
				CloseSequenceFile();
			}
			// 2. Entry identifier list input.
			else if(InParams.sequence.StartsWith("@")) {
				SetIdentifierFile(InParams.sequence.Substring(1));
				string inId = null;
				while((inId = NextIdentifier()) != null) {
					InParams.sequence = inId;
					SubmitJob();
				}
				CloseIdentifierFile();
			}
			// 3. Simple sequence input.
			else {
				InParams.sequence = LoadData(InParams.sequence);
				SubmitJob();
			}
			PrintDebugMessage("SubmitJobs", "End", 1);
		}

		// Implementation of abstract method (AbsractWsClient.SubmitJob()).
		/// <summary>Submit a job to the service</summary>
		public override string SubmitJob()
		{
			PrintDebugMessage("SubmitJob", "Begin", 1);
			JobId = RunApp(Email, JobTitle, InParams);
			if (OutputLevel > 0 || Async) Console.WriteLine(JobId);
			// Simulate sync mode
			if (!Async) GetResults();
			PrintDebugMessage("SubmitJob", "End", 1);
			return JobId;
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
			PrintDebugMessage("RunApp", "input:\n" + ObjectValueToString(input), 2);
			string jobId = null;
			this.ServiceProxyConnect(); // Ensure we have a service proxy
			// Submit the job
			jobId = SrvProxy.run(email, title, input);
			PrintDebugMessage("RunApp", "jobId: " + jobId, 2);
			PrintDebugMessage("RunApp", "End", 1);
			return jobId;
		}

		// Implementation of abstract method (AbsractWsClient.GetStatus()).
		/// <summary>Get the job status</summary>
		/// <param name="jobId">Job identifier to get the status of.</param>
		/// <returns>A string describing the status</returns>
		public override string GetStatus(string jobId)
		{
			PrintDebugMessage("GetStatus", "Begin", 1);
			string status = "PENDING";
			this.ServiceProxyConnect(); // Ensure we have a service proxy
			status = SrvProxy.getStatus(jobId);
			PrintDebugMessage("GetStatus", "status: " + status, 2);
			PrintDebugMessage("GetStatus", "End", 1);
			return status;
		}

		/// <summary>
		/// Get details of the available result types/formats for a completed job. 
		/// </summary>
		/// <param name="jobId">Job identifier
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>An array of result type descriptions.
		/// A <see cref="wsResultType"/>
		/// </returns>
		public wsResultType[] GetResultTypes(string jobId)
		{
			PrintDebugMessage("GetResultTypes", "Begin", 2);
			wsResultType[] resultTypes = SrvProxy.getResultTypes(jobId);
			PrintDebugMessage("GetResultTypes", "End", 2);
			return resultTypes;
		}

		// Implementation of abstract method (AbsractWsClient.PrintResultTypes()).
		/// <summary>Print a summary of the result types for a job</summary>
		public override void PrintResultTypes()
		{
			PrintDebugMessage("PrintResultTypes", "Begin", 1);
			PrintDebugMessage("PrintResultTypes", "JobId: " + JobId, 2);
			this.ServiceProxyConnect(); // Ensure we have a service proxy
			wsResultType[] resultTypes = GetResultTypes(JobId);
			PrintDebugMessage("PrintResultTypes", "resultTypes: " + resultTypes.Length, 2);
			PrintProgressMessage("Getting output formats for job " + JobId, 1);
			foreach(wsResultType resultType in resultTypes)
			{
				Console.WriteLine(resultType.identifier);
				if(resultType.label != null) Console.WriteLine("\t{0}", resultType.label);
				if(resultType.description != null) Console.WriteLine("\t{0}", resultType.description);
				if(resultType.mediaType != null) Console.WriteLine("\t{0}", resultType.mediaType);
				if(resultType.fileSuffix != null) Console.WriteLine("\t{0}", resultType.fileSuffix);
			}
			PrintDebugMessage("PrintResultTypes", "End", 1);
		}

		// Implementation of abstract method (AbsractWsClient.GetResult()).
		public override byte[] GetResult(string jobId, string format)
		{
			PrintDebugMessage("GetResult", "Begin", 1);
			PrintDebugMessage("GetResult", "jobId: " + jobId, 1);
			PrintDebugMessage("GetResult", "format: " + format, 1);
			byte[] result = null;
			result = SrvProxy.getResult(jobId, format, null);
			PrintDebugMessage("GetResult", "End", 1);
			return result;
		}

		// Implementation of abstract method (AbsractWsClient.GetResults()).
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
				PrintDebugMessage("GetResults", "resultType:\n" + ObjectValueToString(selResultType), 2);
				res = GetResult(jobId, selResultType.identifier);
				// Text data
				if (selResultType.mediaType.StartsWith("text"))
				{
					if (OutFile == "-") WriteTextFile(OutFile, res);
					else WriteTextFile(OutFile + "." + selResultType.identifier + "." + selResultType.fileSuffix, res);
				}
				// Binary data
				else
				{
					if (OutFile == "-") WriteBinaryFile(OutFile, res);
					else WriteBinaryFile(OutFile + "." + selResultType.identifier + "." + selResultType.fileSuffix, res);
				}
			}
			else
			{ // Data types available
				// Write a file for each output type
				foreach (wsResultType resultType in resultTypes)
				{
					PrintDebugMessage("GetResults", "resultType:\n" + ObjectValueToString(resultType), 2);
					res = GetResult(jobId, resultType.identifier);
					// Text data
					if (resultType.mediaType.StartsWith("text"))
					{
						if (OutFile == "-") WriteTextFile(OutFile, res);
						else WriteTextFile(OutFile + "." + resultType.identifier + "." + resultType.fileSuffix, res);
					}
					// Binary data
					else
					{
						if (OutFile == "-") WriteBinaryFile(OutFile, res);
						else WriteBinaryFile(OutFile + "." + resultType.identifier + "." + resultType.fileSuffix, res);
					}
				}
			}
			PrintDebugMessage("GetResults", "End", 1);
		}
	}
}
