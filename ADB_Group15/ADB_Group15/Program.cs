using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ADB_Group15
{
    static class Program
    {
        public static readonly string connString = "Server=.;Database=DATH_CSDLNC;Integrated Security=True;";
        //public static TaiKhoan taikhoan = new TaiKhoan();
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new DangNhap());
        }
    }
}
