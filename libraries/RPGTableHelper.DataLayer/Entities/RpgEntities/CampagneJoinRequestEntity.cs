using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities
{
    public class CampagneJoinRequestEntity : EntityBase<Guid>
    {
        [ForeignKey(nameof(User))]
        public Guid UserId { get; set; } = Guid.Empty;
        public virtual UserEntity? User { get; set; }

        [ForeignKey(nameof(Player))]
        public Guid PlayerId { get; set; } = Guid.Empty;
        public virtual PlayerCharacterEntity? Player { get; set; }

        [ForeignKey(nameof(Campagne))]
        public Guid CampagneId { get; set; } = Guid.Empty;
        public virtual CampagneEntity? Campagne { get; set; }
    }
}
