using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;

/// <summary>
/// Descripción breve de SendFcm
/// </summary>
public class SendFcm
{
    private string Api_key = "AIzaSyCGMWQdDbwu0-lchpIiZ9vuO4VaX2mSi7g";
    private string ProjectNumber = "852399133811";
    private string Icon = "ic_launcher";
    private string Title = string.Empty;
    private string Body = string.Empty;
    private string Token = string.Empty;
    public string Response = string.Empty;
    public object Obj = new object();
	public SendFcm()
	{
		//
		// TODO: Agregar aquí la lógica del constructor
		//
	}
    public SendFcm(string token, string title, string body)
    {
        Title = title;
        Body = body;
        Token = token;
        Task.Factory.StartNew(() => SendNotification());
    }

    public SendFcm(string token, object obj)
    {
        Token = token;
        Obj = obj;
        Task.Factory.StartNew(() => SendData());
    }



    public void SendData()
    {
        var SENDER_ID = ProjectNumber;
        var title = Title;
        var value = Body;
        var deviceId = Token;
        WebRequest tRequest;
        tRequest = WebRequest.Create("https://fcm.googleapis.com/fcm/send");
        tRequest.Method = "post";
        tRequest.ContentType = "application/json";
        var header = new
        {
            Authorization = Api_key,
            Sender = new { id = ProjectNumber }
        };

        tRequest.Headers.Add(string.Format("Authorization: key={0}", Api_key));
        tRequest.Headers.Add(string.Format("Sender: id={0}", ProjectNumber));

  
        var data = new
        {
            to = deviceId,
            data = Obj
        };

        var serializer = new JavaScriptSerializer();
        var json = serializer.Serialize(data);

        Byte[] byteArray = Encoding.UTF8.GetBytes(json);
        tRequest.ContentLength = byteArray.Length;

        Stream dataStream = tRequest.GetRequestStream();
        dataStream.Write(byteArray, 0, byteArray.Length);
        dataStream.Close();

        WebResponse tResponse = tRequest.GetResponse();

        dataStream = tResponse.GetResponseStream();

        StreamReader tReader = new StreamReader(dataStream);

        tReader.ReadToEnd();
        tReader.Close();
        dataStream.Close();
        tResponse.Close();

        

    }

    public void SendNotification()
    {
        var SENDER_ID = ProjectNumber;
        var title = Title;
        var value = Body;
        var deviceId = Token;
        WebRequest tRequest;
        tRequest = WebRequest.Create("https://fcm.googleapis.com/fcm/send");
        tRequest.Method = "post";
        tRequest.ContentType = "application/json";
        var header = new
        {
            Authorization = Api_key,
            Sender = new { id = ProjectNumber }
        };

        tRequest.Headers.Add(string.Format("Authorization: key={0}", Api_key));
        tRequest.Headers.Add(string.Format("Sender: id={0}", ProjectNumber));


        var data = new
        {
            to = deviceId,
            notification = new
            {
                body = Body,
                title = Title,
                icon = Icon
            }
        };

        var serializer = new JavaScriptSerializer();
        var json = serializer.Serialize(data);

        Byte[] byteArray = Encoding.UTF8.GetBytes(json);
        tRequest.ContentLength = byteArray.Length;

        Stream dataStream = tRequest.GetRequestStream();
        dataStream.Write(byteArray, 0, byteArray.Length);
        dataStream.Close();

        WebResponse tResponse = tRequest.GetResponse();

        dataStream = tResponse.GetResponseStream();

        StreamReader tReader = new StreamReader(dataStream);

        tReader.ReadToEnd();
        tReader.Close();
        dataStream.Close();
        tResponse.Close();



    }

}