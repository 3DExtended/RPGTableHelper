using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.RpgEntities
{
    public class CampagneJoinRequest : NodeModelBase<CampagneJoinRequest.CampagneJoinRequestIdentifier, Guid>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
        public PlayerCharacter.PlayerCharacterIdentifier PlayerId { get; set; } = default!;
        public Campagne.CampagneIdentifier CampagneId { get; set; } = default!;

        public record CampagneJoinRequestIdentifier : Identifier<Guid, CampagneJoinRequestIdentifier> { }
    }
}
