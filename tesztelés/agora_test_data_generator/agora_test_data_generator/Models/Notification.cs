using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Notification
    {
        public int NotificationId { get; set; }
        public int SenderId { get; set; }
        public int ReciverId { get; set; }
        public string Content { get; set; }
        public string Type { get; set; }
        public int? ItemId { get; set; }
        public string Link { get; set; }
        public bool? Seen { get; set; }
        public DateTime? SentAt { get; set; }

        public virtual Member Reciver { get; set; }
        public virtual Member Sender { get; set; }
    }
}
