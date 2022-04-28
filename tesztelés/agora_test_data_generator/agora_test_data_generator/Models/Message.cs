using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Message
    {
        public int MessageId { get; set; }
        public int SenderId { get; set; }
        public int ReciverId { get; set; }
        public string Message1 { get; set; }
        public DateTime? SentAt { get; set; }

        public virtual Member Reciver { get; set; }
        public virtual Member Sender { get; set; }
    }
}
