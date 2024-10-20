using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities
{
    public class CampagneEntity : EntityBase<Guid>
    {
        /// <summary>
        /// This is the json serialized configuration of the rpg
        /// </summary>
        public string? RpgConfiguration { get; set; }

        public string CampagneName { get; set; } = default!;
        public string JoinCode { get; set; } = default!;

        /// <summary>
        /// The dm of this campagne.
        /// </summary>
        [ForeignKey(nameof(DmUser))]
        public Guid DmUserId { get; set; } = default!;
        public virtual UserEntity? DmUser { get; set; }

        public ICollection<PlayerCharacterEntity>? Characters { get; }
    }
}
