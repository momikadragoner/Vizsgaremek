using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class FollowerRelation
    {
        public int FollowerId { get; set; }
        public int FollowingId { get; set; }

        public virtual Member Follower { get; set; }
        public virtual Member Following { get; set; }
    }
}
