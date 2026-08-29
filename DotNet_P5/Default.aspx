<%@ Page Language="C#" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Academic Calendar & Leave Management</title>

    <style>
        body {
            font-family: Arial;
            margin: 0;
            background-color: #f4f6f9;
        }

        .header {
            background-color: #007bff;
            color: white;
            padding: 20px;
            text-align: center;
        }

        .container {
            width: 80%;
            margin: 30px auto;
        }

        .login-box {
            width: 350px;
            margin: 80px auto;
            padding: 30px;
            background: white;
            box-shadow: 0px 0px 10px gray;
            border-radius: 10px;
        }

        input, textarea, select {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            box-sizing: border-box;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            background: #007bff;
            color: white;
            cursor: pointer;
            border-radius: 5px;
        }

        .btn:hover {
            background: #0056b3;
        }

        .dashboard {
            display: flex;
            justify-content: center;
            gap: 20px;
            flex-wrap: wrap;
            margin-top: 30px;
        }

        .card {
            width: 220px;
            background: white;
            padding: 25px;
            text-align: center;
            border-radius: 10px;
            box-shadow: 0px 3px 10px #aaa;
        }

        .card button {
            background: #007bff;
            color: white;
            border: none;
            padding: 10px;
            cursor: pointer;
            border-radius: 5px;
        }

        .section {
            background: white;
            padding: 30px;
            margin-top: 30px;
            border-radius: 10px;
            box-shadow: 0px 3px 10px #ccc;
        }

        .hidden {
            display: none;
        }

        .message {
            font-weight: bold;
            margin-top: 10px;
        }

        .logout {
            background: #dc3545;
        }
    </style>

    <script runat="server">

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Hide all sections initially
                pnlDashboard.Visible = false;
                pnlCalendar.Visible = false;
                pnlLeave.Visible = false;
                pnlHistory.Visible = false;

                // Check Cookie
                if (Request.Cookies["Username"] != null)
                {
                    txtUsername.Text = Request.Cookies["Username"].Value;
                }

                // If already logged in
                if (Session["Username"] != null)
                {
                    ShowDashboard();
                }
                else
                {
                    pnlLogin.Visible = true;
                }
            }
        }


        // LOGIN BUTTON
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (txtUsername.Text == "admin" &&
                txtPassword.Text == "123")
            {
                // Create Session
                Session["Username"] = txtUsername.Text;

                // Create Cookie
                if (chkRemember.Checked)
                {
                    HttpCookie cookie =
                        new HttpCookie("Username");

                    cookie.Value = txtUsername.Text;
                    cookie.Expires =
                        DateTime.Now.AddDays(7);

                    Response.Cookies.Add(cookie);
                }

                lblLoginMessage.Text = "";

                ShowDashboard();
            }
            else
            {
                lblLoginMessage.ForeColor =
                    System.Drawing.Color.Red;

                lblLoginMessage.Text =
                    "Invalid Username or Password!";
            }
        }


        // SHOW DASHBOARD
        void ShowDashboard()
        {
            pnlLogin.Visible = false;

            pnlDashboard.Visible = true;

            pnlCalendar.Visible = false;
            pnlLeave.Visible = false;
            pnlHistory.Visible = false;

            lblWelcome.Text =
                Session["Username"].ToString();
        }


        // OPEN CALENDAR
        protected void btnCalendar_Click(object sender, EventArgs e)
        {
            pnlDashboard.Visible = false;
            pnlCalendar.Visible = true;
        }


        // OPEN LEAVE APPLICATION
        protected void btnLeave_Click(object sender, EventArgs e)
        {
            pnlDashboard.Visible = false;
            pnlLeave.Visible = true;
        }


        // OPEN LEAVE HISTORY
        protected void btnHistory_Click(object sender, EventArgs e)
        {
            pnlDashboard.Visible = false;
            pnlHistory.Visible = true;

            LoadHistory();
        }


        // CALENDAR DATE SELECT
        protected void AcademicCalendar_SelectionChanged(
            object sender, EventArgs e)
        {
            lblSelectedDate.Text =
                "Selected Date: " +
                AcademicCalendar.SelectedDate
                .ToLongDateString();
        }


        // APPLY LEAVE
        protected void btnApplyLeave_Click(
            object sender, EventArgs e)
        {
            if (calFrom.SelectedDate == DateTime.MinValue ||
                calTo.SelectedDate == DateTime.MinValue)
            {
                lblLeaveMessage.ForeColor =
                    System.Drawing.Color.Red;

                lblLeaveMessage.Text =
                    "Please select both dates.";

                return;
            }

            if (calFrom.SelectedDate > calTo.SelectedDate)
            {
                lblLeaveMessage.ForeColor =
                    System.Drawing.Color.Red;

                lblLeaveMessage.Text =
                    "From Date cannot be greater than To Date.";

                return;
            }

            // Store Leave Data in Session
            Session["LeaveType"] =
                ddlLeaveType.SelectedValue;

            Session["FromDate"] =
                calFrom.SelectedDate.ToShortDateString();

            Session["ToDate"] =
                calTo.SelectedDate.ToShortDateString();

            Session["Reason"] =
                txtReason.Text;

            Session["LeaveStatus"] = "Pending";

            lblLeaveMessage.ForeColor =
                System.Drawing.Color.Green;

            lblLeaveMessage.Text =
                "Leave Applied Successfully!";
        }


        // LOAD LEAVE HISTORY
        void LoadHistory()
        {
            System.Data.DataTable dt =
                new System.Data.DataTable();

            dt.Columns.Add("Username");
            dt.Columns.Add("Leave Type");
            dt.Columns.Add("From Date");
            dt.Columns.Add("To Date");
            dt.Columns.Add("Reason");
            dt.Columns.Add("Status");

            if (Session["LeaveType"] != null)
            {
                dt.Rows.Add(
                    Session["Username"].ToString(),
                    Session["LeaveType"].ToString(),
                    Session["FromDate"].ToString(),
                    Session["ToDate"].ToString(),
                    Session["Reason"].ToString(),
                    Session["LeaveStatus"].ToString()
                );
            }

            GridView1.DataSource = dt;
            GridView1.DataBind();
        }


        // BACK BUTTON
        protected void btnBack_Click(object sender, EventArgs e)
        {
            ShowDashboard();
        }


        // LOGOUT
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();

            pnlDashboard.Visible = false;
            pnlCalendar.Visible = false;
            pnlLeave.Visible = false;
            pnlHistory.Visible = false;

            pnlLogin.Visible = true;

            txtUsername.Text = "";
            txtPassword.Text = "";
        }

    </script>

</head>

<body>

<form id="form1" runat="server">

    <!-- LOGIN PANEL -->
    <asp:Panel ID="pnlLogin" runat="server"
        CssClass="login-box">

        <h2>Login</h2>

        <asp:Label runat="server"
            Text="Username"></asp:Label>

        <asp:TextBox ID="txtUsername"
            runat="server"></asp:TextBox>

        <asp:Label runat="server"
            Text="Password"></asp:Label>

        <asp:TextBox ID="txtPassword"
            runat="server"
            TextMode="Password"></asp:TextBox>

        <br />

        <asp:CheckBox ID="chkRemember"
            runat="server"
            Text="Remember Me" />

        <br /><br />

        <asp:Button ID="btnLogin"
            runat="server"
            Text="Login"
            CssClass="btn"
            OnClick="btnLogin_Click" />

        <br />

        <asp:Label ID="lblLoginMessage"
            runat="server"
            CssClass="message">
        </asp:Label>

    </asp:Panel>


    <!-- DASHBOARD PANEL -->
    <asp:Panel ID="pnlDashboard"
        runat="server">

        <div class="header">

            <h1>
                Academic Calendar & Leave Management System
            </h1>

            <h3>
                Welcome,
                <asp:Label ID="lblWelcome"
                    runat="server">
                </asp:Label>
            </h3>

        </div>


        <div class="dashboard">

            <!-- Calendar Card -->
            <div class="card">

                <h2>📅</h2>

                <h3>Academic Calendar</h3>

                <p>View important academic dates.</p>

                <asp:Button ID="btnCalendar"
                    runat="server"
                    Text="Open Calendar"
                    OnClick="btnCalendar_Click" />

            </div>


            <!-- Leave Card -->
            <div class="card">

                <h2>📝</h2>

                <h3>Apply Leave</h3>

                <p>Submit a leave application.</p>

                <asp:Button ID="btnLeave"
                    runat="server"
                    Text="Apply Leave"
                    OnClick="btnLeave_Click" />

            </div>


            <!-- History Card -->
            <div class="card">

                <h2>📋</h2>

                <h3>Leave History</h3>

                <p>View your leave applications.</p>

                <asp:Button ID="btnHistory"
                    runat="server"
                    Text="View History"
                    OnClick="btnHistory_Click" />

            </div>

        </div>

        <br />

        <center>

            <asp:Button ID="btnLogout"
                runat="server"
                Text="Logout"
                CssClass="btn logout"
                OnClick="btnLogout_Click" />

        </center>

    </asp:Panel>


    <!-- CALENDAR SECTION -->
    <asp:Panel ID="pnlCalendar"
        runat="server"
        CssClass="container">

        <div class="section">

            <h2>Academic Calendar</h2>

            <asp:Calendar
                ID="AcademicCalendar"
                runat="server"
                OnSelectionChanged=
                "AcademicCalendar_SelectionChanged">

                <SelectedDayStyle
                    BackColor="Blue"
                    ForeColor="White" />

            </asp:Calendar>

            <br />

            <asp:Label ID="lblSelectedDate"
                runat="server">
            </asp:Label>

            <br /><br />

            <asp:Button
                runat="server"
                Text="Back to Dashboard"
                CssClass="btn"
                OnClick="btnBack_Click" />

        </div>

    </asp:Panel>


    <!-- LEAVE APPLICATION SECTION -->
    <asp:Panel ID="pnlLeave"
        runat="server"
        CssClass="container">

        <div class="section">

            <h2>Apply Leave</h2>

            <p>Leave Type</p>

            <asp:DropDownList
                ID="ddlLeaveType"
                runat="server">

                <asp:ListItem>
                    Casual Leave
                </asp:ListItem>

                <asp:ListItem>
                    Medical Leave
                </asp:ListItem>

                <asp:ListItem>
                    Academic Leave
                </asp:ListItem>

            </asp:DropDownList>


            <h4>From Date</h4>

            <asp:Calendar
                ID="calFrom"
                runat="server">
            </asp:Calendar>


            <h4>To Date</h4>

            <asp:Calendar
                ID="calTo"
                runat="server">
            </asp:Calendar>


            <p>Reason</p>

            <asp:TextBox
                ID="txtReason"
                runat="server"
                TextMode="MultiLine"
                Rows="4">
            </asp:TextBox>

            <br />

            <asp:Button
                ID="btnApplyLeave"
                runat="server"
                Text="Apply Leave"
                CssClass="btn"
                OnClick="btnApplyLeave_Click" />

            <br /><br />

            <asp:Label
                ID="lblLeaveMessage"
                runat="server">
            </asp:Label>

            <br /><br />

            <asp:Button
                runat="server"
                Text="Back to Dashboard"
                CssClass="btn"
                OnClick="btnBack_Click" />

        </div>

    </asp:Panel>


    <!-- LEAVE HISTORY SECTION -->
    <asp:Panel ID="pnlHistory"
        runat="server"
        CssClass="container">

        <div class="section">

            <h2>Leave History</h2>

            <asp:GridView
                ID="GridView1"
                runat="server"
                AutoGenerateColumns="true">
            </asp:GridView>

            <br />

            <asp:Button
                runat="server"
                Text="Back to Dashboard"
                CssClass="btn"
                OnClick="btnBack_Click" />

        </div>

    </asp:Panel>

</form>

</body>
</html>