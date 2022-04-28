using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Session
    {
        public int SessionId { get; set; }
        public int MemberId { get; set; }
        public string Jwt { get; set; }
        public DateTime LoggedInAt { get; set; }

        public virtual Member Member { get; set; }
    }
}
