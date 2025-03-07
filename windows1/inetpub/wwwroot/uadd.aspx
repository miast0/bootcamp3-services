<%@ Page Language="C#" %>
<%@ Import namespace="System.Diagnostics"%>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.DirectoryServices.AccountManagement" %>
<%@ Import Namespace="System.Security.Cryptography" %>
using System.Web

<script runat="server">

    static byte[] urlsafe_b64(string s)
    {
        string incoming = s.Replace('_', '/').Replace('-', '+');
        switch (s.Length % 4)
        {
            case 2: incoming += "=="; break;
            case 3: incoming += "="; break;
        }
        return Convert.FromBase64String(incoming);

    }
	
    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnEnroll_Click(object sender, EventArgs e)
    {
    	 PrincipalContext principalContext = null;
            try
            {
                principalContext = new PrincipalContext(ContextType.Domain);
                var token = txtToken.Text.Trim();
                // since username is just passed in html encode to prevent xss. Ive no clue what the real vuln is
                var username = HttpUtility.HtmlEncode(token.Split('.')[0]);
                var signature = urlsafe_b64(token.Split('.')[1]);

                var rsa = new RSACryptoServiceProvider();
                rsa.FromXmlString("<RSAKeyValue><Modulus>4lFfXTLbDgQCnGbR6rlA9HtXPAogsnCNJhNzev6ulDDjTLty5pgHl5VZqJ6JB3oPCH2qFakfRSyTHXM/NhCQQY0qXJ48CK/q7niS4QD1v+CLccUWqW1DkzAfrJtmzUiKLDXHspSA8HrCtXAQiLIBV0xN2h+UnthDKI6L21EbUS07RMHBZ9iCr9/crIZ8JGSepB6AXcNAViNso3UDP45sdx9hRilNRVxL4Hqk3YHMsavNXHYqbpVLGoKoxO1utgthEXZDSw/zJxJ0NOEWbvDiHJpGyz9mFh9aupfL4qVljVxndlUJDUEN3arPsCCLKDykJ4J7VFGR9JbH61gYLbeCyw==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>");
                if(!rsa.VerifyData(Encoding.ASCII.GetBytes(username), "SHA256", signature))
                {
                    Response.Write("bad token");
                    Response.End();
                }


                UserPrincipal usr = UserPrincipal.FindByIdentity(principalContext, username);


                if (usr != null)
                {

                    result.Text = username + " already exists. Please use a different User Logon Name.";

                }
                else
                {
                    UserPrincipal userPrincipal = new UserPrincipal(principalContext);
                    


                    userPrincipal.Surname = username;
                    userPrincipal.GivenName = username;


                    userPrincipal.EmailAddress = "a@b.com";

                    userPrincipal.UserPrincipalName = username + "@adorad.local";
                    userPrincipal.SamAccountName = username;

                    userPrincipal.DisplayName = username;
                    userPrincipal.SetPassword(txtPassword.Text);

                    userPrincipal.Enabled = true;
                    userPrincipal.PasswordNeverExpires = true;


                    userPrincipal.Save();
                    result.Text = "User " + username  + " created sucessfully";
              }
            }

            catch (Exception ex)
            {
                result.Text = "Exception: " + ex;

            }
    }

</script>

</script>


<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Self-enrollment</title>
        <link rel="stylesheet" href="simple.css">
    </head>
<body>  
    
    <header>
        <h1>Create an account</h1>
   

      </header>

      <main>

        <b>Note: Since one employee (PÅ™emysl Å˜eÅ™ichÃ¡Ä) kept breaking our active directory with his name we now pre-generate a username for you</b>
        
        <form id="formEnroll" runat="server">
            <p>
                <label>Username:</label>
                <input type="text" disabled="disabled">
            </p>
            <p>
                <label>Token:</label>
                <asp:TextBox id="txtToken" runat="server" TextMode="MultiLine" Rows="10" width="100%"></asp:TextBox>
            </p>
            <p>
                <label>Password:</label>
                <asp:TextBox ID="txtPassword" runat="server" width="100%"></asp:TextBox>
            </p>
            <asp:Button ID="btnEnroll" runat="server" OnClick="btnEnroll_Click" Text="Enroll" />
        </form>
        <asp:Label id="result" runat="server"></asp:Label>
      </main>




</body>
</html>
