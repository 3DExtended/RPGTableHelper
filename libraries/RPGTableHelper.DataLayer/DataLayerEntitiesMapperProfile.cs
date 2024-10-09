using AutoMapper;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer
{
    public class DataLayerEntitiesMapperProfile : Profile
    {
        public DataLayerEntitiesMapperProfile()
        {
            CreateModelMaps<User, User.UserIdentifier, Guid, UserEntity>();
            CreateModelMaps<
                EncryptionChallenge,
                EncryptionChallenge.EncryptionChallengeIdentifier,
                Guid,
                EncryptionChallengeEntity
            >();
        }

        private void CreateModelMaps<TModel, TIdentifier, TIdentifierValue, TEntity>()
            where TModel : ModelBase<TIdentifier, TIdentifierValue>, new()
            where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        {
            CreateMap<TIdentifier, TIdentifierValue>().ConvertUsing((tmid, _) => tmid.Value);
            CreateMap<TIdentifierValue, TIdentifier>()
                .ConvertUsing((id, _) => Identifier<TIdentifierValue, TIdentifier>.From(id));

            CreateMap<TModel, TEntity>().ReverseMap();
        }
    }
}
