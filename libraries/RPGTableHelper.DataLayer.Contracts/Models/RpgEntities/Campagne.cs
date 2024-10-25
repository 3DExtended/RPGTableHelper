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
    public class Campagne : NodeModelBase<Campagne.CampagneIdentifier, Guid>
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
        public User.UserIdentifier DmUserId { get; set; } = default!;

        public record CampagneIdentifier : Identifier<Guid, CampagneIdentifier> { }
    }
}
